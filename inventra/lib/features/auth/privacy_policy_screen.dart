import 'package:flutter/material.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.privacyPolicy),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.privacyPolicy,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last Updated: June 11, 2026',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            _section(
              '',
              'Welcome to Inventra ("we," "our," or "us"). Your privacy is important to us. '
              'This Privacy Policy explains how Inventra collects, uses, stores, and protects '
              'your information when you use our mobile application and related services.',
            ),
            _section('1. Information We Collect', null),
            _subsection('Account Information', [
              'Name',
              'Email address',
              'Password (stored securely in encrypted form)',
            ]),
            _subsection('Business Information', [
              'Store names and locations',
              'Product information',
              'Inventory records',
              'Sales and transaction data',
              'Employee accounts and permissions',
            ]),
            _subsection('Device Information', [
              'Device type',
              'Operating system version',
              'App version',
              'Error and crash reports',
            ]),
            _subsection('Barcode Scanner Access', [
              'Inventra may request camera access solely for scanning product barcodes. '
                  'Images and videos are not stored unless explicitly uploaded by the user.',
            ]),
            _section('2. How We Use Your Information', null, bullets: [
              'Provide inventory and sales management services',
              'Process and record transactions',
              'Generate statistics and business reports',
              'Improve app performance and user experience',
              'Send important service notifications',
              'Maintain account security',
            ]),
            _section('3. Data Storage and Security',
                'We implement reasonable security measures to protect your information from '
                'unauthorized access, alteration, disclosure, or destruction.\n\n'
                'User passwords are stored using secure encryption and hashing methods. '
                'Authentication tokens are used to maintain secure access to the platform.\n\n'
                'While we strive to protect your information, no method of transmission or '
                'storage is 100% secure.'),
            _section('4. Sharing of Information',
                'We do not sell, rent, or trade your personal information.\n\n'
                'We may share information only:\n'
                '• When required by law\n'
                '• To protect the security and integrity of our services\n'
                '• With trusted service providers that help operate our platform'),
            _section('5. Analytics and Reporting',
                'Inventra may analyze sales, inventory, and business activity to generate '
                'reports, insights, forecasts, and recommendations for store owners. '
                'These analytics are used solely to improve business management features.'),
            _section('6. Data Retention',
                'We retain your data while your account remains active and as necessary to '
                'provide our services. You may request deletion of your account and associated '
                'data at any time, subject to legal or operational requirements.'),
            _section('7. Your Rights', null, bullets: [
              'Access your data',
              'Correct inaccurate information',
              'Request deletion of your data',
              'Export your data',
              'Withdraw consent where applicable',
            ]),
            _section('8. Children\'s Privacy',
                'Inventra is intended for business users and is not directed toward children '
                'under the age of 13. We do not knowingly collect information from children.'),
            _section('9. Changes to This Privacy Policy',
                'We may update this Privacy Policy from time to time. Updated versions will be '
                'posted within the application and will become effective upon publication.'),
            _section('10. Contact Us',
                'If you have any questions about this Privacy Policy or our privacy practices, '
                'please contact us at:\n\nEmail: support@inventra.app'),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'By using Inventra, you acknowledge that you have read and agree to this Privacy Policy.',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, String? body, {List<String>? bullets}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (title.isNotEmpty) const SizedBox(height: 8),
          if (body != null)
            Text(body, style: const TextStyle(height: 1.5, fontSize: 15)),
          if (bullets != null) ...[
            const SizedBox(height: 4),
            ...bullets.map(
              (b) => Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 15)),
                    Expanded(
                      child: Text(b, style: const TextStyle(height: 1.5, fontSize: 15)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _subsection(String title, List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const SizedBox(height: 4),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontSize: 14)),
                  Expanded(child: Text(item, style: const TextStyle(height: 1.4))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
