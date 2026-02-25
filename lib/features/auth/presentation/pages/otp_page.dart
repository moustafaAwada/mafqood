import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mafqood/features/auth/presentation/cubit/auth_cubit.dart';

class OtpPage extends StatefulWidget {
  static const routeName = '/otp';
  final String email;

  const OtpPage({super.key, required this.email});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  // final OtpFieldController _otpController = OtpFieldController();
  final String _enteredCode = "";
  int _secondsRemaining = 60;
  bool _enableResend = false;
  Timer? _timer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        setState(() {
          _enableResend = true;
        });
        _timer?.cancel();
      }
    });
  }

  Future<void> _verifyOtp() async {
    // final l10n = AppLocalizations.of(context)!;
    if (_enteredCode.length < 6) {
      // Fluttertoast.showToast(msg: l10n.invalidOtp);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // final auth = context.read<AuthCubit>();
      // final success = await auth.verifyEmailOtp(widget.email, _enteredCode);

      // if (success) {
      //   if (!mounted) return;
      //   _showSuccessBottomSheet();
      // } else {
      //   Fluttertoast.showToast(msg: l10n.invalidOtp);
      // }
    } catch (e) {
      // Fluttertoast.showToast(msg: l10n.authFailed);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _resendOtp() async {
    // final l10n = AppLocalizations.of(context)!;
    try {
      final auth = context.read<AuthCubit>();
      // final success = await auth.sendEmailOtp(widget.email);
      // if (success) {
      // Fluttertoast.showToast(msg: l10n.otpSentSuccess);
      //   setState(() {
      //     _secondsRemaining = 60;
      //     _enableResend = false;
      //   });
      //   _startTimer();
      // }
    } catch (e) {
      // Fluttertoast.showToast(msg: l10n.authFailed);
    }
  }

  void _showSuccessBottomSheet() {
    // final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          height: 400,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                // color: AppColors.primary,
                size: 100,
              ),
              const SizedBox(height: 24),
              Text(
                'accountVerified',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  // color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'accountReady',
                style: const TextStyle(
                  fontSize: 16,
                  // color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigator.of(context).pushNamedAndRemoveUntil(
                    //   MainScreen.routeName,
                    //   (route) => false,
                    // );
                  },
                  style: ElevatedButton.styleFrom(
                    // backgroundColor: AppColors.primary,
                    // foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'startExploring',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      // backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.close,
            //  color: AppColors.textPrimary
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Image.asset(
                "assets/images/edited-photo.png",
                height: 100,
                width: 100,
              ),
              const SizedBox(height: 32),
              Text(
                'otpAlmostThere',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  // color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.email,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  // color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 48),
              // OTPTextField(
              //   controller: _otpController,
              //   length: 6,
              //   width: MediaQuery.of(context).size.width,
              //   fieldWidth: 45,
              //   style: const TextStyle(
              //     fontSize: 20,
              //     color: AppColors.textPrimary,
              //   ),
              //   textFieldAlignment: MainAxisAlignment.spaceAround,
              //   fieldStyle: FieldStyle.box,
              //   onChanged: (pin) {
              //     setState(() {
              //       _enteredCode = pin;
              //     });
              //   },
              //   otpFieldStyle: OtpFieldStyle(
              //     focusBorderColor: AppColors.primary,
              //     enabledBorderColor: Colors.grey.shade300,
              //     disabledBorderColor: Colors.grey.shade100,
              //   ),
              // ),
              const Spacer(),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      // backgroundColor: AppColors.primary,
                      // foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'continueButton',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _enableResend ? _resendOtp : null,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 50),
                  side: BorderSide(
                    // color: _enableResend ? AppColors.primary : Colors.grey,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _enableResend ? 'resendCode' : "$_secondsRemaining ",
                  style: TextStyle(
                    // color: _enableResend ? AppColors.primary : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
