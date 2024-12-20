import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/target.dart';
import '../../providers/target_provider.dart';

class TargetSettingScreen extends StatefulWidget {
  const TargetSettingScreen({Key? key}) : super(key: key);

  @override
  State<TargetSettingScreen> createState() => _TargetSettingScreenState();
}

class _TargetSettingScreenState extends State<TargetSettingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _revenueController = TextEditingController();
  final _registrationController = TextEditingController();
  final _reregistrationController = TextEditingController();
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _loadCurrentTarget();
  }

  @override
  void dispose() {
    _revenueController.dispose();
    _registrationController.dispose();
    _reregistrationController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentTarget() async {
    final target = context.read<TargetProvider>().currentTarget;
    if (target != null) {
      setState(() {
        _revenueController.text = target.revenueTarget.toString();
        _registrationController.text = target.registrationTarget.toString();
        _reregistrationController.text = target.reregistrationTarget.toString();
        _dateRange = DateTimeRange(
          start: target.startDate,
          end: target.endDate,
        );
      });
    }
  }

  Future<void> _selectDateRange() async {
    final initialDateRange = _dateRange ?? DateTimeRange(
      start: DateTime.now(),
      end: DateTime.now().add(const Duration(days: 30)),
    );

    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: initialDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            appBarTheme: const AppBarTheme(
              systemOverlayStyle: SystemUiOverlayStyle.light,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedRange != null) {
      setState(() {
        _dateRange = pickedRange;
      });
    }
  }

  Future<void> _saveTarget() async {
    if (!_formKey.currentState!.validate() || _dateRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final target = Target(
      id: context.read<TargetProvider>().currentTarget?.id ?? '',
      revenueTarget: double.parse(_revenueController.text),
      registrationTarget: int.parse(_registrationController.text),
      reregistrationTarget: int.parse(_reregistrationController.text),
      startDate: _dateRange!.start,
      endDate: _dateRange!.end,
    );

    try {
      if (target.id.isEmpty) {
        await context.read<TargetProvider>().createTarget(target);
      } else {
        await context.read<TargetProvider>().updateTarget(
          target.id,
          target.toMap(),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Target saved successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving target: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Targets'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Target Period',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: _selectDateRange,
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          _dateRange == null
                              ? 'Select Period'
                              : '${_dateRange!.start.toString().split(' ')[0]} - '
                                '${_dateRange!.end.toString().split(' ')[0]}',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Revenue Target',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _revenueController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          prefixText: '\$ ',
                          hintText: 'Enter target revenue',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter revenue target';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Registration Targets',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _registrationController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'New registrations target',
                          prefixIcon: Icon(Icons.business),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter registrations target';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _reregistrationController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Re-registrations target',
                          prefixIcon: Icon(Icons.refresh),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter re-registrations target';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _saveTarget,
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Save Targets'),
          ),
        ),
      ),
    );
  }
} 