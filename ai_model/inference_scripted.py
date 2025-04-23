import requests
import cv2
import numpy as np
from ultralytics import YOLO
import time
import serial
import threading
from collections import deque, Counter
from flask import Flask, jsonify
from flask_cors import CORS  # <-- Added this

# Initialize YOLO model and class names
model = YOLO("best.pt")
class_names = model.names
url = "http://192.168.1.208/capture"

# Shared variables
last_label = {'label': None, 'timestamp': 0}
distance = None
label_history = deque(maxlen=3)

# For Flask server to share final detected label
final_detected_label = None

# Flask app setup
app = Flask(__name__)
CORS(app)  # <-- Enable CORS for all routes

@app.route('/detected_label')
def get_label():
    global final_detected_label
    return jsonify({'label': final_detected_label or "none"})

def flask_thread():
    # Run Flask server on all interfaces, port 5000
    app.run(host='0.0.0.0', port=5000)

def brighten_image(img, value=50):
    hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
    h, s, v = cv2.split(hsv)

    lim = 255 - value
    v[v > lim] = 255
    v[v <= lim] += value

    final_hsv = cv2.merge((h, s, v))
    bright_img = cv2.cvtColor(final_hsv, cv2.COLOR_HSV2BGR)
    return bright_img

def read_serial(port='COM13', baudrate=9600):
    global distance
    try:
        ser = serial.Serial(port, baudrate, timeout=1)
    except Exception as e:
        print(f"Failed to open serial port: {e}")
        return

    while True:
        try:
            line = ser.readline().decode('utf-8').strip()
            if len(line) <= 2 and line != "":
                try:
                    distance = int(line)
                except ValueError:
                    print(f"Invalid distance value: {line}")
        except Exception as e:
            print(f"Serial read error: {e}")
            break

    ser.close()

def majority_label(labels):
    if not labels:
        return None
    count = Counter(labels)
    return count.most_common(1)[0][0]

def run_yolo_loop():
    global last_label
    while True:
        try:
            response = requests.get(url, timeout=5)
            img_array = np.asarray(bytearray(response.content), dtype=np.uint8)
            frame = cv2.imdecode(img_array, cv2.IMREAD_COLOR)

            bright_frame = brighten_image(frame, value=50)

            cv2.imshow("Brightened Frame", bright_frame)
            if cv2.waitKey(1) & 0xFF == ord('q'):
                break

            results = model(bright_frame, verbose=False)
            probs_tensor = results[0].probs.data
            probs = probs_tensor.cpu().numpy()

            max_idx = probs.argmax()
            predicted_name = class_names[max_idx]

            label_history.append(predicted_name)
            maj_label = majority_label(label_history)

            last_label['label'] = maj_label
            last_label['timestamp'] = time.time()

        except Exception as e:
            print("YOLO error:", e)
        time.sleep(0.1)

# Start serial reading in a separate thread
serial_thread = threading.Thread(target=read_serial, daemon=True)
serial_thread.start()

# Start YOLO detection loop in a separate thread
yolo_thread = threading.Thread(target=run_yolo_loop, daemon=True)
yolo_thread.start()

# Start Flask server thread to serve the label via HTTP
flask_server_thread = threading.Thread(target=flask_thread, daemon=True)
flask_server_thread.start()

# Variables for close-distance event tracking
detected_while_close = []
close_event_active = False
final_label_for_close_event = None

try:
    while True:
        time.sleep(0.1)
        label = last_label['label']
        label_age = time.time() - last_label['timestamp']
        label_to_show = label if label is not None and label_age <= 2 else None

        if distance is not None:
            print(f"Distance: {distance} cm | Detected type: {label_to_show or 'No recent detection'}")

            if distance < 10:
                close_event_active = True
                if label_to_show is not None:
                    detected_while_close.append(label_to_show)
            else:
                if close_event_active:
                    if detected_while_close:
                        count = Counter(detected_while_close)
                        final_label_for_close_event = count.most_common(1)[0][0]
                        print(f"Final detected type when close: {final_label_for_close_event}, sending to app")
                        final_detected_label = final_label_for_close_event
                        time.sleep(4)
                    else:
                        final_label_for_close_event = None
                        final_detected_label = None

                    detected_while_close.clear()
                    close_event_active = False
        else:
            print("Waiting for distance data...")

except KeyboardInterrupt:
    print("Exiting...")
finally:
    cv2.destroyAllWindows()
