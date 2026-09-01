import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_colors.dart';

/// A "Buy me a coffee" card that opens a Stripe payment link in the browser.
///
/// WHY THE BROWSER AND NOT AN IN-APP CHECKOUT
/// App Store guideline 3.2.2(iv) forbids collecting funds inside an app for
/// charities and fundraisers unless you are an Apple approved nonprofit, and
/// says such funds "may only collect funds outside of the app, such as via
/// Safari". Framing this as a tip to the developer rather than a charity
/// keeps it clear of that rule, and opening the link externally keeps it
/// clear of the in-app purchase rules too, since nothing digital is unlocked
/// by paying.
///
/// Nothing in the app changes when someone pays. That is deliberate: a
/// payment tied to unlocking content would have to use in-app purchase under
/// 3.2.1(vii).
class BuyMeACoffee extends StatelessWidget {
  /// The Stripe payment link. Left empty until one is configured, in which
  /// case the card hides itself rather than opening a dead URL.
  static const String paymentLink = String.fromEnvironment(
    'COFFEE_LINK',
    defaultValue: '',
  );

  const BuyMeACoffee({super.key});

  static bool get isConfigured => paymentLink.isNotEmpty;

  Future<void> _open(BuildContext context) async {
    final uri = Uri.tryParse(paymentLink);
    if (uri == null) return;

    // externalApplication opens the real browser rather than an in-app web
    // view, which is what the guideline asks for.
    final opened =
        await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the payment page.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isConfigured) return const SizedBox.shrink();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _open(context),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              const Text('☕', style: TextStyle(fontSize: 26)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Buy Me a Coffee',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'This app is free with no ads. A coffee helps keep it '
                      'that way.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.open_in_new, color: Colors.grey[400], size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
