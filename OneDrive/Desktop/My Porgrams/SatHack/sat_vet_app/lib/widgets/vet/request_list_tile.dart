import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sat_vet_app/models/farm_model.dart';

class RequestListTile extends StatelessWidget {
  final Farm farm;
  final VoidCallback onApprove;
  final VoidCallback onDeny;

  const RequestListTile({
    Key? key,
    required this.farm,
    required this.onApprove,
    required this.onDeny,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const FaIcon(FontAwesomeIcons.userPlus, size: 20),
      title: Text(farm.name),
      subtitle: Text(farm.owner),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.check, color: Colors.green),
            onPressed: onApprove,
            tooltip: 'Approve',
          ),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.xmark, color: Colors.red),
            onPressed: onDeny,
            tooltip: 'Deny',
          ),
        ],
      ),
    );
  }
}
