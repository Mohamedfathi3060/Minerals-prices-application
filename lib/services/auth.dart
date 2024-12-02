import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:minerals_prices/models/user.dart';
import 'package:minerals_prices/pages/Home.dart';
import 'package:minerals_prices/pages/login.dart';
import 'package:minerals_prices/services/users.dart';

class AuthService {
  Future<void> signup(
      {required final String email,
        required final String password,
        required final BuildContext context}) async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      final user =
      UserModel(username: "anything", email: email, password: password);
      final userService = UserService();
      await userService.createUser(user);
      await Future.delayed(const Duration(seconds: 1));
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (BuildContext context) => const Home()));
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists with that email.';
        print('An account already exists with that email.');
      } else {
        print(email);
        message = 'An account already exists with that email.';
        print('Something went wrong in singing you up');
      }

      //  Fluttertoast.showToast(
      //   msg: message,
      //   toastLength: Toast.LENGTH_LONG,
      //   gravity: ToastGravity.SNACKBAR,
      //   backgroundColor: Colors.black54,
      //   textColor: Colors.white,
      //   fontSize: 14.0,
      // );
    }
  }

  Future<void> signin(
      {required String email,
        required String password,
        required BuildContext context}) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      await Future.delayed(const Duration(seconds: 1));
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (BuildContext context) => const Home()));
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'invalid-email') {
        print(email);
        print("HHHHHHHHHHHHHHHHHHHHHHHHHH");
        print(e);
        message = 'No user found for that email.';
      } else if (e.code == 'invalid-credential') {
        message = 'Wrong password provided for that user.';
      }
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    } catch (e) {}
  }

  Future<void> signout({required BuildContext context}) async {
    await FirebaseAuth.instance.signOut();
    await Future.delayed(const Duration(seconds: 1));
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (BuildContext context) => Login()));
  }
}
