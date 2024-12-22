// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
//
// class PhoneAuthPage extends StatefulWidget {
//   @override
//   _PhoneAuthPageState createState() => _PhoneAuthPageState();
// }
//
// class _PhoneAuthPageState extends State<PhoneAuthPage> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _otpController = TextEditingController();
//
//   String? _verificationId;
//
//   void _verifyPhoneNumber() async {
//     final String phoneNumber = _phoneController.text.trim();
//     if (phoneNumber.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: Text("Please enter a phone number"),
//       ));
//       return;
//     }
//
//     await _auth.verifyPhoneNumber(
//       phoneNumber: "+201024068783",
//       verificationCompleted: (PhoneAuthCredential credential) async {
//         // Auto-retrieval case
//         print("Success Mobile verfication");
//         print(credential);
//         await _auth.signInWithCredential(credential);
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//           content: Text("Phone number verified and user signed in!"),
//         ));
//       },
//       verificationFailed: (FirebaseAuthException e) {
//         print("Failed Mobile verfication");
//         print(e);
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//           content: Text("Verification failed: ${e.message}"),
//         ));
//       },
//       codeSent: (String verificationId, int? resendToken) {
//         print("code sent");
//         print(verificationId);
//         setState(() {
//           _verificationId = verificationId;
//         });
//
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//           content: Text("OTP sent to $phoneNumber"),
//         ));
//       },
//       codeAutoRetrievalTimeout: (String verificationId) {
//         setState(() {
//           _verificationId = verificationId;
//         });
//       },
//     );
//   }
//
//   void _verifyOTP() async {
//     final String otp = _otpController.text.trim();
//     if (_verificationId == null || otp.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: Text("Please enter the OTP"),
//       ));
//       return;
//     }
//
//     try {
//       PhoneAuthCredential credential = PhoneAuthProvider.credential(
//         verificationId: _verificationId!,
//         smsCode: otp,
//       );
//
//       await _auth.signInWithCredential(credential);
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: Text("Phone number verified and user signed in!"),
//       ));
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: Text("Invalid OTP"),
//       ));
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Phone Number Authentication"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             TextField(
//               controller: _phoneController,
//               decoration: InputDecoration(
//                 labelText: "Phone Number",
//                 prefixText: "+",
//                 border: OutlineInputBorder(),
//               ),
//               keyboardType: TextInputType.phone,
//             ),
//             SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _verifyPhoneNumber,
//               child: Text("Send OTP"),
//             ),
//             SizedBox(height: 16),
//             TextField(
//               controller: _otpController,
//               decoration: InputDecoration(
//                 labelText: "OTP",
//                 border: OutlineInputBorder(),
//               ),
//               keyboardType: TextInputType.number,
//             ),
//             SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _verifyOTP,
//               child: Text("Verify OTP"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PhoneAuthPage extends StatefulWidget {
  @override
  _PhoneAuthPageState createState() => _PhoneAuthPageState();
}

class _PhoneAuthPageState extends State<PhoneAuthPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  String? _verificationId;

  void _verifyPhoneNumber() async {
    final String phoneNumber = _phoneController.text.trim();
    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please enter a phone number"),
      ));
      return;
    }

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-retrieval case
        await _auth.signInWithCredential(credential);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Phone number verified and user signed in!"),
        ));
      },
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Verification failed: ${e.message}"),
        ));
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("OTP sent to $phoneNumber"),
        ));
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          _verificationId = verificationId;
        });
      },
    );
  }

  void _verifyOTP() async {
    final String otp = _otpController.text.trim();
    if (_verificationId == null || otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please enter the OTP"),
      ));
      return;
    }

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      await _auth.signInWithCredential(credential);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Phone number verified and user signed in!"),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Invalid OTP"),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Phone Number Authentication"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: "Phone Number",
                prefixText: "+",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _verifyPhoneNumber,
              child: Text("Send OTP"),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _otpController,
              decoration: InputDecoration(
                labelText: "OTP",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _verifyOTP,
              child: Text("Verify OTP"),
            ),
          ],
        ),
      ),
    );
  }
}
