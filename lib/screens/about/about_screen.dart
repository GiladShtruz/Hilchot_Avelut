import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';

/// About screen with app information and contact details
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const String _developerEmail = 'gilad@example.com'; // Replace with actual email
  static const String _davidEmail = 'david@example.com'; // Replace with actual email

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('אודות'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.menu_book,
                color: Colors.white,
                size: 50,
              ),
            ),
            const SizedBox(height: 24),
            
            // App Name
            Text(
              'הלכות אבלות',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            
            // Version
            Text(
              'גרסה 1.0.0',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
            ),
            const SizedBox(height: 32),
            
            // Welcome text
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'שלום לכולם,',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'מוזמנים לצפות באפליקציית הלכות אבלות.',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 20),
                  
                  // Developer info
                  _buildInfoRow(
                    context,
                    icon: Icons.code,
                    label: 'פיתוח האפליקציה',
                    value: 'גילעד שטרוזמן',
                  ),
                  const SizedBox(height: 16),
                  
                  // Content author info
                  _buildInfoRow(
                    context,
                    icon: Icons.edit,
                    label: 'כתיבת התוכן',
                    value: 'דוד',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Contact section
            Text(
              'ליצירת קשר',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Contact buttons
            _buildContactButton(
              context,
              icon: Icons.email,
              label: 'שלח מייל למפתח',
              email: _developerEmail,
              subject: 'פנייה מאפליקציית הלכות אבלות',
            ),
            const SizedBox(height: 12),
            _buildContactButton(
              context,
              icon: Icons.email_outlined,
              label: 'שלח מייל לדוד',
              email: _davidEmail,
              subject: 'פנייה מאפליקציית הלכות אבלות',
            ),
            
            const SizedBox(height: 40),
            
            // Copyright
            Text(
              '© ${DateTime.now().year} כל הזכויות שמורות',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.secondaryTextColor,
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String email,
    required String subject,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _sendEmail(context, email, subject),
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Future<void> _sendEmail(BuildContext context, String email, String subject) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': subject,
      },
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('לא ניתן לפתוח אפליקציית מייל. כתובת: $email'),
              action: SnackBarAction(
                label: 'העתק',
                onPressed: () {
                  // Copy email to clipboard would go here
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('שגיאה בפתיחת אפליקציית המייל')),
        );
      }
    }
  }
}
