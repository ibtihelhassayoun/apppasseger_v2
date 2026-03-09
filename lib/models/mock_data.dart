class MockData {
  static const List<Map<String, dynamic>> vehicles = [
    {
      'id': 'Bus 1A',
      'line': 'Ligne A',
      'lat': 48.8566,
      'lng': 2.3522,
      'occupancy': 'Faible',
      'color': 0xFF4CAF50, // Green
    },
    {
      'id': 'Tram 3',
      'line': 'Ligne T3',
      'lat': 48.8606,
      'lng': 2.3422,
      'occupancy': 'Moyen',
      'color': 0xFFFF9800, // Orange
    },
    {
      'id': 'Bus 42',
      'line': 'Ligne B',
      'lat': 48.8516,
      'lng': 2.3622,
      'occupancy': 'Élevé',
      'color': 0xFFF44336, // Red
    },
  ];

  static const List<Map<String, dynamic>> etas = [
    {'stop': 'Gare Centrale', 'line': 'Ligne A', 'eta': '3 min', 'status': 'À l\'heure'},
    {'stop': 'Université', 'line': 'Ligne B', 'eta': '7 min', 'status': 'Retardé'},
    {'stop': 'Centre Ville', 'line': 'Ligne T3', 'eta': '12 min', 'status': 'À l\'heure'},
    {'stop': 'Hôpital', 'line': 'Ligne A', 'eta': '15 min', 'status': 'À l\'heure'},
  ];

  static const List<Map<String, dynamic>> networkStatus = [
    {'line': 'Ligne A', 'status': 'Trafic fluide', 'icon': 0xe156}, // check_circle
    {'line': 'Ligne B', 'status': 'Trafic ralenti', 'icon': 0xe6e0}, // warning
    {'line': 'Ligne C', 'status': 'Interrompue', 'icon': 0xe24c}, // error
    {'line': 'Ligne T3', 'status': 'Trafic fluide', 'icon': 0xe156},
  ];

  static const List<Map<String, dynamic>> notifications = [
    {
      'title': 'Alerte Ligne B',
      'message': 'En raison de travaux, le trafic est ralenti sur la Ligne B.',
      'time': 'Il y a 10 min',
      'type': 'alert'
    },
    {
      'title': 'Nouveau Service',
      'message': 'Découvrez le nouveau mode sombre de l\'application !',
      'time': 'Il y a 2 heures',
      'type': 'info'
    },
  ];

  static const List<Map<String, dynamic>> tripHistory = [
    {
      'route': 'Tunis (Gare de Barcelone) → Nabeul',
      'date': 'Hier, 14:30',
      'price': '8.50',
      'icon': 0xe1d5, // directions_bus
    },
    {
      'route': 'Sousse → Monastir',
      'date': '24 Mai, 09:15',
      'price': '3.20',
      'icon': 0xe661, // train
    },
    {
      'route': 'Bizerte → Tunis (Aéroport)',
      'date': '20 Mai, 06:00',
      'price': '12.00',
      'icon': 0xe1d5, // directions_bus
    },
    {
      'route': 'Sfax → Gabès',
      'date': '15 Mai, 16:45',
      'price': '15.50',
      'icon': 0xe661, // train
    },
  ];
}
