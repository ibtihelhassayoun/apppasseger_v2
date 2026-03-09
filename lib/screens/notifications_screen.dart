import 'dart:math';
import 'package:flutter/material.dart';
import '../main.dart';
import '../models/mock_data.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late List<Map<String, dynamic>> _notifications;
  late List<Map<String, dynamic>> _networkStatus;

  // Alert templates based on transport state
  static const Map<String, List<String>> _alertTemplates = {
    'Retardé': [
      '{line} est retardée de quelques minutes en raison d\'un incident technique.',
      'Retard signalé sur {line}. Temps d\'attente supplémentaire estimé : 5 à 10 min.',
      'Attention : {line} accuse un retard. Suivez les mises à jour en temps réel.',
    ],
    'Trafic ralenti': [
      'Le trafic est actuellement ralenti sur {line}. Prévoyez un délai supplémentaire.',
      '{line} : Circulation perturbée en raison d\'un afflux de passagers.',
      'Ralentissement sur {line} dû à des travaux sur la voie.',
    ],
    'Interrompue': [
      'Service interrompu sur {line}. Des bus de substitution sont mis en place.',
      '{line} est momentanément hors service. Reprise estimée dans 30 min.',
      'Interruption totale sur {line} suite à un incident. Nous travaillons à la reprise du service.',
    ],
    'Annulé': [
      'Le voyage sur {line} a été annulé. Veuillez consulter les alternatives disponibles.',
      'Annulation exceptionnelle sur {line}. Un remboursement automatique sera effectué.',
    ],
  };

  static String _generateAlertMessage(String line, String status) {
    final templates = _alertTemplates[status] ?? [
      'Perturbation signalée sur $line. Statut : $status.',
    ];
    final msg = templates[Random().nextInt(templates.length)];
    return msg.replaceAll('{line}', line);
  }

  static String _timeAgo() {
    final options = [
      'Il y a 2 min', 'Il y a 5 min', 'Il y a 10 min',
      'Il y a 15 min', 'Il y a 30 min', 'Il y a 1 heure',
    ];
    return options[Random().nextInt(options.length)];
  }

  void _generateData() {
    // Transport alerts from ETA data
    final List<Map<String, dynamic>> transportAlerts = MockData.etas
        .where((e) => e['status'] != "À l'heure")
        .map((e) => {
              'title': 'Alerte ${e['line']}',
              'message': _generateAlertMessage(e['line'] as String, e['status'] as String),
              'time': _timeAgo(),
              'type': 'alert',
              'status': e['status'],
            })
        .toList();

    // Network alerts from networkStatus data
    final List<Map<String, dynamic>> networkAlerts = MockData.networkStatus
        .where((s) => s['status'] != 'Trafic fluide')
        .map((s) => {
              'title': '${s['status']} — ${s['line']}',
              'message': _generateAlertMessage(s['line'] as String, s['status'] as String),
              'time': _timeAgo(),
              'type': 'alert',
              'status': s['status'],
            })
        .toList();

    // Combine all notifications, shuffle, keep at most 6
    final all = [
      ...transportAlerts,
      ...networkAlerts,
      ...MockData.notifications,
    ]..shuffle();

    setState(() {
      _notifications = all.take(6).toList();
      _networkStatus = List.of(MockData.networkStatus)..shuffle();
    });
    // Update global badge count with number of alert-type messages
    alertCountNotifier.value = _notifications.where((n) => n['type'] == 'alert').length;
  }

  @override
  void initState() {
    super.initState();
    _notifications = [];
    _networkStatus = [];
    _generateData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Actualités & Alertes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
            onPressed: _generateData,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Alertes en direct',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF11215D)),
          ),
          const SizedBox(height: 16),
          ..._notifications.map((n) => _buildNotificationCard(n)),
          const SizedBox(height: 32),
          const Text(
            'État du réseau',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF11215D)),
          ),
          const SizedBox(height: 16),
          ..._networkStatus.map((s) => _buildStatusRow(s)),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Trafic fluide':
        return Colors.green;
      case 'Trafic ralenti':
        return Colors.orange;
      case 'Interrompue':
        return Colors.red;
      case 'Retardé':
        return Colors.deepOrange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildNotificationCard(Map<String, dynamic> n) {
    final bool isAlert = n['type'] == 'alert';
    final Color cardColor = isAlert ? Colors.red : Colors.blue;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isAlert ? Icons.warning_amber_rounded : Icons.info_outline,
            color: cardColor,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        n['title'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      n['time'] as String,
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  n['message'] as String,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(Map<String, dynamic> s) {
    final color = _statusColor(s['status'] as String);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  IconData(s['icon'] as int, fontFamily: 'MaterialIcons'),
                  size: 16,
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Text(s['line'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              s['status'] as String,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
