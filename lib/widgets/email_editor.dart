import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class EmailEditor extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final VoidCallback? onSend;
  final bool isSending;

  const EmailEditor({
    Key? key,
    required this.controller,
    this.focusNode,
    this.onSend,
    this.isSending = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.edit_note, color: AppTheme.brandTeal),
                SizedBox(width: 8),
                Text(
                  'Compose Email',
                  style: TextStyle(
                    color: AppTheme.brandBlack,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Spacer(),
                if (isSending)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.brandTeal),
                    ),
                  )
                else
                  IconButton(
                    icon: Icon(Icons.send_rounded),
                    color: AppTheme.brandTeal,
                    onPressed: onSend,
                    tooltip: 'Send Email',
                  ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                maxLines: null,
                style: TextStyle(
                  fontSize: 15,
                  color: AppTheme.brandBlack,
                  height: 1.5,
                ),
                decoration: InputDecoration(
                  hintText: 'Write your email here...',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
