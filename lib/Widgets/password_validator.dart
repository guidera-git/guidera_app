import 'package:flutter/material.dart';
import 'package:guidera_app/theme/app_colors.dart';

class PasswordValidator extends StatelessWidget {
  final String password;

  const PasswordValidator({
    Key? key,
    required this.password,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          'Password Requirements:',
          style: TextStyle(
            color: AppColors.textSecondary(context),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        _ValidationItem(
          text: 'At least 8 characters',
          isValid: password.length >= 8,
        ),
        _ValidationItem(
          text: 'Contains uppercase letter',
          isValid: password.contains(RegExp(r'[A-Z]')),
        ),
        _ValidationItem(
          text: 'Contains lowercase letter',
          isValid: password.contains(RegExp(r'[a-z]')),
        ),
        _ValidationItem(
          text: 'Contains number',
          isValid: password.contains(RegExp(r'[0-9]')),
        ),
        _ValidationItem(
          text: 'Contains special character',
          isValid: password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')),
        ),
      ],
    );
  }
}

class _ValidationItem extends StatelessWidget {
  final String text;
  final bool isValid;

  const _ValidationItem({
    Key? key,
    required this.text,
    required this.isValid,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: isValid ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: isValid ? Colors.green : Colors.red,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}