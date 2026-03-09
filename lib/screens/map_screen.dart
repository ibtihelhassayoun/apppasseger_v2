import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'eta_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _currentPosController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  LatLng? _currentLocation;
  LatLng? _destinationLocation;
  List<LatLng> _routePoints = [];
  bool _isLoading = false;

  // Centre de la Tunisie par défaut
  final LatLng _tunisiaCenter = const LatLng(36.8065, 10.1815);

  @override
  void initState() {
    super.initState();
    _initPosition();
  }

  Future<void> _initPosition() async {
    // Essayer de récupérer la position mais ne pas bloquer si refusé
    try {
      final status = await Geolocator.checkPermission();
      if (status == LocationPermission.whileInUse || status == LocationPermission.always) {
        _determinePosition();
      } else {
        // Centrer sur Tunis par défaut
        setState(() {
          _currentLocation = _tunisiaCenter;
        });
      }
    } catch (e) {
      debugPrint('Permission error: $e');
    }
  }

  Future<void> _determinePosition() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      final location = LatLng(position.latitude, position.longitude);
      setState(() {
        _currentLocation = location;
        _mapController.move(location, 14.0);
      });
      _getAddressFromLatLng(location, isStart: true);
    } catch (e) {
      debugPrint('Position error: $e');
    }
  }

  Future<void> _getAddressFromLatLng(LatLng position, {required bool isStart}) async {
    try {
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?lat=${position.latitude}&lon=${position.longitude}&format=json');
      final response = await http.get(url, headers: {'User-Agent': 'passenger_app'});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['display_name'].split(',')[0];
        setState(() {
          if (isStart) {
            _currentPosController.text = address;
          } else {
            _destinationController.text = address;
          }
        });
      }
    } catch (e) {
      debugPrint('Reverse geocoding error: $e');
    }
  }

  Future<void> _searchLocation(String query, {required bool isStart}) async {
    if (query.isEmpty) return;
    setState(() => _isLoading = true);

    try {
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=1&countrycodes=tn');
      final response = await http.get(url, headers: {'User-Agent': 'passenger_app'});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.isNotEmpty) {
          final lat = double.parse(data[0]['lat']);
          final lon = double.parse(data[0]['lon']);
          final location = LatLng(lat, lon);
          final displayName = data[0]['display_name'].split(',')[0];

          setState(() {
            if (isStart) {
              _currentLocation = location;
              _currentPosController.text = displayName;
            } else {
              _destinationLocation = location;
              _destinationController.text = displayName;
            }
          });

          _mapController.move(location, 14.0);
          
          if (_currentLocation != null && _destinationLocation != null) {
            _fetchRoute(_currentLocation!, _destinationLocation!);
          }
        } else {
          _showError('Aucun lieu trouvé en Tunisie pour "$query"');
        }
      }
    } catch (e) {
      _showError('Erreur de recherche. Vérifiez votre connexion.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchRoute(LatLng start, LatLng end) async {
    setState(() => _isLoading = true);
    try {
      final url = Uri.parse(
          'https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final geometry = data['routes'][0]['geometry']['coordinates'] as List;
          setState(() {
            _routePoints = geometry.map((coord) => LatLng(coord[1], coord[0])).toList();
          });
          _fitBounds();
        } else {
          _showError('Aucun itinéraire routier trouvé.');
        }
      }
    } catch (e) {
      _showError('Erreur lors du calcul du trajet.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _fitBounds() {
    if (_routePoints.isEmpty) return;
    final bounds = LatLngBounds.fromPoints(_routePoints);
    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: SafeArea(
        child: Column(
          children: [
            // Panel de saisie supérieur (Plus interactif)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildEditableField(
                      icon: Icons.my_location,
                      color: Colors.blue,
                      hint: 'Position de départ',
                      controller: _currentPosController,
                      onSubmitted: (val) => _searchLocation(val, isStart: true),
                    ),
                    const Divider(height: 24, indent: 40),
                    _buildEditableField(
                      icon: Icons.location_on,
                      color: Colors.red,
                      hint: 'Où allez-vous ?',
                      controller: _destinationController,
                      onSubmitted: (val) => _searchLocation(val, isStart: false),
                    ),
                  ],
                ),
              ),
            ),

            // Carte
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _tunisiaCenter,
                        initialZoom: 12.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.passenger_app',
                        ),
                        if (_routePoints.isNotEmpty)
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: _routePoints,
                                color: Colors.blueAccent, // Bleu électrique vibrant
                                strokeWidth: 8.0,
                                strokeCap: StrokeCap.round,
                              ),
                            ],
                          ),
                        MarkerLayer(
                          markers: [
                            if (_currentLocation != null)
                              Marker(
                                point: _currentLocation!,
                                width: 60,
                                height: 60,
                                child: const Icon(Icons.location_history, color: Colors.blue, size: 40),
                              ),
                            if (_destinationLocation != null)
                              Marker(
                                point: _destinationLocation!,
                                width: 70,
                                height: 70,
                                child: const Icon(Icons.location_on, color: Colors.red, size: 50),
                              ),
                          ],
                        ),
                      ],
                    ),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator(color: Color(0xFF11215D))),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: () async {
                    // Si la destination n'est pas encore résolue mais qu'il y a du texte, on cherche
                    if (_destinationLocation == null && _destinationController.text.isNotEmpty) {
                      await _searchLocation(_destinationController.text, isStart: false);
                    }
                    
                    if (_destinationLocation != null) {
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const EtaScreen()),
                        );
                      }
                    } else {
                      _showError('Veuillez sélectionner une destination valide.');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF11215D),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 4,
                  ),
                  child: const Text('Confirmer le trajet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField({
    required IconData icon,
    required Color color,
    required String hint,
    required TextEditingController controller,
    required Function(String) onSubmitted,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: controller,
            onSubmitted: onSubmitted,
            textInputAction: TextInputAction.search,
            style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF11215D)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
              border: InputBorder.none,
              isDense: true,
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (controller.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                      onPressed: () => setState(() => controller.clear()),
                    ),
                  IconButton(
                    icon: Icon(Icons.search, color: color, size: 22),
                    onPressed: () => onSubmitted(controller.text),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _currentPosController.dispose();
    _destinationController.dispose();
    super.dispose();
  }
}
