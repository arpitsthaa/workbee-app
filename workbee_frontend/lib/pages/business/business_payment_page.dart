import 'package:flutter/material.dart';
import 'package:workbee_frontend/clients/business_client.dart';
import 'package:workbee_frontend/constants/app_colors.dart';

/// Demo payment page shown after filling the gig form.
/// Shows a static WorkBee QR, simulates a payment check, then posts the gig on Done.
class BusinessPaymentPage extends StatefulWidget {
  final Map<String, dynamic> gigData;

  const BusinessPaymentPage({super.key, required this.gigData});

  @override
  State<BusinessPaymentPage> createState() => _BusinessPaymentPageState();
}

enum _Stage { pay, checking, confirmed }

class _BusinessPaymentPageState extends State<BusinessPaymentPage> {
  _Stage _stage = _Stage.pay;
  bool _isPosting = false;

  Future<void> _startCheck() async {
    setState(() => _stage = _Stage.checking);
    await Future<void>.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;
    setState(() => _stage = _Stage.confirmed);
  }

  Future<void> _finish() async {
    if (_isPosting) return;
    setState(() => _isPosting = true);

    final result = await BusinessClient.postGig(widget.gigData);

    if (!mounted) return;

    if (result.containsKey('error')) {
      setState(() => _isPosting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] as String? ?? 'Failed to post gig'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final budget = widget.gigData['budget_npr'];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.darkText,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Complete payment',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.darkText,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Scan to pay',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Pay for this gig to publish it.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.mutedText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    child: Image.asset(
                      'assets/workbee_qr.png',
                      width: 220,
                      height: 220,
                      fit: BoxFit.contain,
                    ),
                  ),
                  if (budget != null) ...[
                    const SizedBox(height: 20),
                    Text(
                      'NPR $budget',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  _buildAction(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAction() {
    switch (_stage) {
      case _Stage.pay:
        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _startCheck,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'I have paid',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      case _Stage.checking:
        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              disabledBackgroundColor:
                  AppColors.primaryBlue.withValues(alpha: 0.6),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Checking payment...',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        );
      case _Stage.confirmed:
        return Column(
          children: [
            const Icon(
              Icons.check_circle,
              color: AppColors.successGreen,
              size: 56,
            ),
            const SizedBox(height: 12),
            const Text(
              'Payment confirmed',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isPosting ? null : _finish,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isPosting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Done',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        );
    }
  }
}