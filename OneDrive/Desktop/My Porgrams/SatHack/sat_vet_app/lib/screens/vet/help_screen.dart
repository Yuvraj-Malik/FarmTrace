import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            'Frequently Asked Questions',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildHelpTile(
            question: 'What is a "Compliance Score"?',
            answer:
                'This is the percentage of animals on a farm that are "Clear" and not within an active drug withdrawal period. A higher score is better.',
          ),
          _buildHelpTile(
            question: 'How do I approve a new farm?',
            answer:
                'New farm requests appear on your Dashboard and in the "Pending Requests" tab on the "My Farms" screen. You can approve or deny them from there.',
          ),
          _buildHelpTile(
            question: 'What does "Submit Official Record" do?',
            answer:
                'When you create a new prescription, you are submitting an official, immutable record to the blockchain. This ensures the animal\'s history is secure and verifiable.',
          ),
        ],
      ),
    );
  }

  Widget _buildHelpTile({required String question, required String answer}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16.0),
      // ExpansionTile is a built-in widget for accordions
      child: ExpansionTile(
        leading: const FaIcon(FontAwesomeIcons.circleQuestion),
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
            child: Text(answer),
          ),
        ],
      ),
    );
  }
}
