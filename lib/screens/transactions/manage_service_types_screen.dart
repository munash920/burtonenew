import 'package:flutter/material.dart';
import '../../models/transaction.dart';

class ManageServiceTypesScreen extends StatefulWidget {
  final List<ServiceType> serviceTypes;

  ManageServiceTypesScreen({required this.serviceTypes});

  @override
  _ManageServiceTypesScreenState createState() => _ManageServiceTypesScreenState();
}

class _ManageServiceTypesScreenState extends State<ManageServiceTypesScreen> {
  late List<ServiceType> _serviceTypes;

  @override
  void initState() {
    super.initState();
    _serviceTypes = widget.serviceTypes;
    _serviceTypes.add(ServiceType.bookkeeping);
  }

  void _addServiceType(ServiceType type) {
    setState(() {
      _serviceTypes.add(type);
    });
  }

  void _removeServiceType(ServiceType type) {
    setState(() {
      _serviceTypes.remove(type);
    });
  }

  void _editServiceType(int index, ServiceType newType) {
    setState(() {
      _serviceTypes[index] = newType;
    });
  }

  void _showEditDialog({ServiceType? type, int? index}) {
    String newTypeName = type != null ? type.toString().split('.').last : '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(type == null ? 'Add Service Type' : 'Edit Service Type'),
          content: TextField(
            decoration: InputDecoration(hintText: 'Enter service type name'),
            onChanged: (value) {
              newTypeName = value;
            },
            controller: TextEditingController(text: newTypeName),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                if (newTypeName.isNotEmpty) {
                  setState(() {
                    if (type == null) {
                      _serviceTypes.add(ServiceType.values.first); // Add logic to handle new type
                    } else if (index != null) {
                      _serviceTypes[index] = ServiceType.values.first; // Update logic for editing
                    }
                  });
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Service Types'),
        actions: [
          // Removed the add button functionality
        ],
      ),
      body: ReorderableListView(
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (newIndex > oldIndex) newIndex -= 1;
            final item = _serviceTypes.removeAt(oldIndex);
            _serviceTypes.insert(newIndex, item);
          });
        },
        children: _serviceTypes.map((type) {
          return ListTile(
            key: UniqueKey(),
            title: Text(type.toString().split('.').last),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _removeServiceType(type),
            ),
            onTap: () => _showEditDialog(type: type, index: _serviceTypes.indexOf(type)),
          );
        }).toList(),
      ),
    );
  }
}
