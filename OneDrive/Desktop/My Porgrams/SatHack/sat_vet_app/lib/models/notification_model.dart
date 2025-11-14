import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final IconData icon;
  final Color iconColor;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.icon,
    this.iconColor = Colors.grey,
  });
}

// Mock data for the service
final List<AppNotification> mockNotifications = [
  AppNotification(
    id: 'n1',
    title: 'New Farm Request',
    body: 'Ramesh Dairy Farm wants to link with you.',
    timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    icon: FontAwesomeIcons.userPlus,
    iconColor: Colors.blue.shade700,
  ),
  AppNotification(
    id: 'n2',
    title: 'Compliance Alert',
    body: 'Sita Farm compliance has dropped to 85%.',
    timestamp: DateTime.now().subtract(const Duration(hours: 4)),
    icon: FontAwesomeIcons.shieldHalved,
    iconColor: Colors.orange.shade800,
  ),
  AppNotification(
    id: 'n3',
    title: 'Prescription Submitted',
    body: 'Your prescription for #102-B was successfully recorded.',
    timestamp: DateTime.now().subtract(const Duration(days: 1)),
    icon: FontAwesomeIcons.fileMedical,
    iconColor: Colors.green.shade600,
  ),
];
