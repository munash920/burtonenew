import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../models/transaction.dart';
import '../../services/export_service.dart';
import '../dashboard/widgets/date_range_selector.dart';
import '../transactions/add_transaction_screen.dart';
import 'package:shimmer/shimmer.dart';

// ... (previous code remains the same until _getServiceColor)

  Color _getServiceColor(ServiceType type) {
    switch (type) {
      case ServiceType.registration:
        return Colors.blue;
      case ServiceType.reregistration:
        return Colors.purple;
      case ServiceType.tax_clearance:
        return Colors.orange;
      case ServiceType.tax_returns:
        return Colors.teal;
      case ServiceType.annual_returns:
        return Colors.indigo;
      case ServiceType.bookkeeping:
        return Colors.brown;
    }
  }

  IconData _getServiceIcon(ServiceType type) {
    switch (type) {
      case ServiceType.registration:
        return Icons.app_registration;
      case ServiceType.reregistration:
        return Icons.autorenew;
      case ServiceType.tax_clearance:
        return Icons.check_circle_outline;
      case ServiceType.tax_returns:
        return Icons.description_outlined;
      case ServiceType.annual_returns:
        return Icons.calendar_today;
      case ServiceType.bookkeeping:
        return Icons.book_outlined;
    }
  }

// ... (rest of the code remains the same)
