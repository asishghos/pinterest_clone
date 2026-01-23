// import 'dart:developer' as developer;
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:clerk_auth/clerk_auth.dart' as clerk;
// import '../providers/auth_provider.dart';

// class OtpPage extends ConsumerStatefulWidget {
//   final String email;

//   const OtpPage({super.key, required this.email});

//   @override
//   ConsumerState<OtpPage> createState() => _OtpPageState();
// }

// class _OtpPageState extends ConsumerState<OtpPage> {
//   final _otpController = TextEditingController();
//   bool _isLoading = false;
//   String? _errorMessage;

//   Future<void> _verifyOtp() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     try {
//       final clerkAuth = ref.read(clerkAuthProvider);

//       await clerkAuth.attemptEmailAddressVerification(
//         code: _otpController.text.trim(),
//       );

//       developer.log("OTP verified");

//       final session = clerkAuth.session;

//       if (session != null) {
//         await ref.read(authProvider.notifier).signIn(session.id);

//         developer.log("SESSION CREATED: ${session.id}");

//         if (mounted) {
//           Navigator.pushNamedAndRemoveUntil(context, "/home", (route) => false);
//         }
//       } else {
//         throw Exception("Session still null after OTP");
//       }
//     } catch (e) {
//       developer.log("OTP Error: $e");

//       setState(() {
//         _errorMessage = "Invalid OTP. Try again.";
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _resendOtp() async {
//     final clerkAuth = ref.read(clerkAuthProvider);
//     await clerkAuth.prepareEmailAddressVerification();
//   }

//   @override
//   void dispose() {
//     _otpController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Verify Email")),
//       body: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           children: [
//             Text(
//               "Enter the OTP sent to",
//               style: Theme.of(context).textTheme.titleMedium,
//             ),
//             const SizedBox(height: 6),
//             Text(
//               widget.email,
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 32),

//             TextField(
//               controller: _otpController,
//               keyboardType: TextInputType.number,
//               decoration: InputDecoration(
//                 labelText: "OTP Code",
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 24),

//             if (_errorMessage != null)
//               Text(_errorMessage!, style: const TextStyle(color: Colors.red)),

//             const SizedBox(height: 16),

//             FilledButton(
//               onPressed: _isLoading ? null : _verifyOtp,
//               child: _isLoading
//                   ? const CircularProgressIndicator(color: Colors.white)
//                   : const Text("Verify OTP"),
//             ),

//             TextButton(onPressed: _resendOtp, child: const Text("Resend OTP")),
//           ],
//         ),
//       ),
//     );
//   }
// }
