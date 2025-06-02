/// Ordre des pays pour le parcours circulaire de Kuma
class Countries {
  static const Map<String, String> COUNTRY_ORDER = {
    "South Africa": "ZAF",
    "Lesotho": "LSO",
    "Eswatini": "SWZ",
    "Namibia": "NAM",
    "Botswana": "BWA",
    "Zimbabwe": "ZWE",
    "Zambia": "ZMB",
    "Malawi": "MWI",
    "Mozambique": "MOZ",
    "Madagascar": "MDG",
    "Mauritius": "MUS",
    "Comoros": "COM",
    "Tanzania": "TZA",
    "Burundi": "BDI",
    "Rwanda": "RWA",
    "Uganda": "UGA",
    "Kenya": "KEN",
    "Seychelles": "SYC",
    "Somalia": "SOM",
    "Ethiopia": "ETH",
    "Eritrea": "ERI",
    "Djibouti": "DJI",
    "South Sudan": "SSD",
    "Sudan": "SDN",
    "Egypt": "EGY",
    "Libya": "LBY",
    "Tunisia": "TUN",
    "Algeria": "DZA",
    "Morocco": "MAR",
    "Mauritania": "MRT",
    "Cape Verde": "CPV",
    "Senegal": "SEN",
    "The Gambia": "GMB",
    "Guinea-Bissau": "GNB",
    "Guinea": "GIN",
    "Sierra Leone": "SLE",
    "Liberia": "LBR",
    "Cote d'Ivoire": "CIV",
    "Ghana": "GHA",
    "Togo": "TGO",
    "Benin": "BEN",
    "Nigeria": "NGA",
    "Niger": "NER",
    "Mali": "MLI",
    "Burkina Faso": "BFA",
    "Chad": "TCD",
    "Central African Republic": "CAF",
    "Cameroon": "CMR",
    "Equatorial Guinea": "GNQ",
    "Gabon": "GAB",
    "Republic of the Congo": "COG",
    "Democratic Republic of the Congo": "COD",
    "Angola": "AGO",
    "Sao Tome and Principe": "STP"
  };

  /// Premier 10 pays pour les données de test
  static const List<String> TEST_COUNTRIES = [
    "Cote d'Ivoire",
    "Ghana", 
    "Nigeria",
    "Cameroon",
    "Kenya",
    "Ethiopia",
    "Egypt",
    "Morocco",
    "Senegal",
    "South Africa"
  ];

  /// Coordonnées relatives (%) pour positionner les story cards sur la carte
  static const Map<String, Map<String, double>> COUNTRY_POSITIONS = {
    "Cote d'Ivoire": {"x": 0.18, "y": 0.52},
    "Ghana": {"x": 0.22, "y": 0.52},
    "Nigeria": {"x": 0.28, "y": 0.50},
    "Cameroon": {"x": 0.35, "y": 0.55},
    "Kenya": {"x": 0.70, "y": 0.60},
    "Ethiopia": {"x": 0.68, "y": 0.48},
    "Egypt": {"x": 0.58, "y": 0.20},
    "Morocco": {"x": 0.20, "y": 0.15},
    "Senegal": {"x": 0.05, "y": 0.38},
    "South Africa": {"x": 0.55, "y": 0.92},
  };

  /// Obtenir le prochain pays dans l'ordre
  static String getNextCountry(String currentCountry) {
    final countries = COUNTRY_ORDER.keys.toList();
    final currentIndex = countries.indexOf(currentCountry);
    if (currentIndex == -1) return countries.first;
    
    final nextIndex = (currentIndex + 1) % countries.length;
    return countries[nextIndex];
  }

  /// Vérifier si le tour est complet (retour au pays de départ)
  static bool isFullTourComplete(String currentCountry, String startCountry) {
    return currentCountry == startCountry;
  }
}