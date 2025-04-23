
class CO2Calculator {
  // Constants for CO2 calculations based on IPCC and EPA standards
  static const double _kWhToCO2 = 0.475; // kg CO2 per kWh (Tunisia's grid average)
  
  // Recycling CO2 savings factors (kg CO2 saved per kg of material)
  static const Map<String, double> _recyclingFactors = {
    'paper': 0.8,    // EPA Waste Reduction Model (WARM)
    'cardboard': 0.9,
    'plastic': 1.5,  // Based on PET recycling
    'metal': 2.0,    // Aluminum recycling
    'glass': 0.3,    // EPA WARM
    'organic': 0.4,  // Composting
  };

  // Landfill emissions factors (kg CO2e per kg of waste)
  static const Map<String, double> _landfillFactors = {
    'paper': 0.12,   // Including methane emissions
    'plastic': 0.15,
    'metal': 0.05,
    'glass': 0.05,
    'organic': 0.3,  // Higher due to methane production
    'other': 0.1,
  };

  // Transportation emissions (kg CO2 per km per kg)
  static const double _transportEmissions = 0.0001;

  // Calculate CO2 emissions from electricity usage
  static double calculateElectricityCO2({
    required double kWh,
    double? renewablePercentage, // Optional: percentage of renewable energy
  }) {
    final double baseEmissions = kWh * _kWhToCO2;
    if (renewablePercentage != null) {
      return baseEmissions * (1 - (renewablePercentage / 100));
    }
    return baseEmissions;
  }

  // Calculate CO2 savings from recycling including transportation
  static double calculateRecyclingCO2Savings({
    required Map<String, double> materials, // kg of each material
    required double transportDistance, // km to recycling facility
  }) {
    double totalSavings = 0.0;
    double transportEmissions = 0.0;
    double totalWeight = 0.0;

    materials.forEach((material, weight) {
      if (_recyclingFactors.containsKey(material)) {
        totalSavings += weight * _recyclingFactors[material]!;
        totalWeight += weight;
      }
    });

    // Calculate transportation emissions
    transportEmissions = totalWeight * transportDistance * _transportEmissions;

    return totalSavings - transportEmissions;
  }

  // Calculate CO2 emissions from landfill including methane
  static double calculateLandfillCO2({
    required Map<String, double> materials,
    required double transportDistance,
    double methaneCaptureEfficiency = 0.0, // Percentage of methane captured
  }) {
    double landfillEmissions = 0.0;
    double transportEmissions = 0.0;
    double totalWeight = 0.0;

    materials.forEach((material, weight) {
      if (_landfillFactors.containsKey(material)) {
        // Convert to CO2e (including methane)
        double emissions = weight * _landfillFactors[material]!;
        // Account for methane capture
        emissions *= (1 - (methaneCaptureEfficiency / 100));
        landfillEmissions += emissions;
        totalWeight += weight;
      }
    });

    // Calculate transportation emissions
    transportEmissions = totalWeight * transportDistance * _transportEmissions;

    return landfillEmissions + transportEmissions;
  }

  // Calculate total CO2 impact (negative means net savings)
  static double calculateTotalCO2Impact({
    required double electricityKWh,
    required Map<String, double> recycledMaterials,
    required Map<String, double> landfilledMaterials,
    required double recyclingTransportDistance,
    required double landfillTransportDistance,
    double? renewablePercentage,
    double methaneCaptureEfficiency = 0.0,
  }) {
    final double electricityCO2 = calculateElectricityCO2(
      kWh: electricityKWh,
      renewablePercentage: renewablePercentage,
    );

    final double recyclingSavings = calculateRecyclingCO2Savings(
      materials: recycledMaterials,
      transportDistance: recyclingTransportDistance,
    );

    final double landfillCO2 = calculateLandfillCO2(
      materials: landfilledMaterials,
      transportDistance: landfillTransportDistance,
      methaneCaptureEfficiency: methaneCaptureEfficiency,
    );

    return electricityCO2 - recyclingSavings + landfillCO2;
  }

  // Convert CO2 to equivalent trees needed to offset
  static int calculateEquivalentTrees(double co2Kg) {
    // Based on EPA's estimate of 21.77 kg CO2 absorbed per tree per year
    const double co2PerTreePerYear = 21.77;
    return (co2Kg / co2PerTreePerYear).ceil();
  }

  // Convert CO2 to equivalent car kilometers
  static double calculateEquivalentCarKm(double co2Kg) {
    // Based on EPA's estimate of 0.118 kg CO2 per km for average car
    const double co2PerKm = 0.118;
    return co2Kg / co2PerKm;
  }

  // Get formatted impact message with detailed breakdown
  static String getImpactMessage({
    required double co2Kg,
    required double electricityCO2,
    required double recyclingSavings,
    required double landfillCO2,
  }) {
    final int trees = calculateEquivalentTrees(co2Kg.abs());
    final double carKm = calculateEquivalentCarKm(co2Kg.abs());
    
    final StringBuffer message = StringBuffer();
    
    if (co2Kg < 0) {
      message.writeln('You have saved ${co2Kg.abs().toStringAsFixed(2)} kg of CO2!');
      message.writeln('\nBreakdown:');
      message.writeln('- Electricity: ${electricityCO2.toStringAsFixed(2)} kg CO2');
      message.writeln('- Recycling savings: ${recyclingSavings.toStringAsFixed(2)} kg CO2');
      message.writeln('- Landfill: ${landfillCO2.toStringAsFixed(2)} kg CO2');
      message.writeln('\nThis is equivalent to:');
      message.writeln('- Planting $trees trees');
      message.writeln('- Not driving ${carKm.toStringAsFixed(1)} km');
    } else {
      message.writeln('Your current CO2 impact is ${co2Kg.toStringAsFixed(2)} kg');
      message.writeln('\nBreakdown:');
      message.writeln('- Electricity: ${electricityCO2.toStringAsFixed(2)} kg CO2');
      message.writeln('- Recycling savings: ${recyclingSavings.toStringAsFixed(2)} kg CO2');
      message.writeln('- Landfill: ${landfillCO2.toStringAsFixed(2)} kg CO2');
      message.writeln('\nTo offset this, you would need:');
      message.writeln('- $trees trees');
      message.writeln('- Or reduce driving by ${carKm.toStringAsFixed(1)} km');
    }
    
    return message.toString();
  }
} 