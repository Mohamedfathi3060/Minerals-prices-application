import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:minerals_prices/models/user.dart';
import 'package:minerals_prices/pages/Home.dart';
import 'package:minerals_prices/pages/login.dart';
import 'package:minerals_prices/services/users.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_analytics/firebase_analytics.dart';


class AuthService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future signInWithGoogle({required BuildContext context}) async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // User canceled the Google Sign-In process
        Get.snackbar("Sign-In Cancelled", "No account was selected.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange.withOpacity(0.1),
            colorText: Colors.orange);
        return;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
      await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      final userCredentials =
      await FirebaseAuth.instance.signInWithCredential(credential);

      final User? user = userCredentials.user;

      if (user != null) {
        final userService = UserService();
        final emailExists = await userService.doesEmailExist(user.email!);

        if (!emailExists) {
          // Create a new user if email does not exist
          final userModel = UserModel(
            username: user.displayName,
            email: user.email,
            password: "no password googlesignedin",
          );
          await userService.createUser(userModel);
        } else {
          Get.snackbar("Welcome Back", "You are already registered.",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green.withOpacity(0.1),
              colorText: Colors.green);
        }
      }

      final displayName = user?.displayName; // Get the username
      print("Userrrrrrrrname  $displayName");

      await _analytics.logEvent(
        name: 'first_login',
      );
      // Navigate to Home after successful sign-in
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const Home()));
    } catch (e) {
      print("Error during Google Sign-In: $e");
      Get.snackbar("Error", "Failed to sign in with Google.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withOpacity(0.1),
          colorText: Colors.red);
    }
  }

  Future<void> signup(
      {required final String email,
        required final String password,
        /////////////////////////
        required final String username,
        ///////////////////////////////
        required final BuildContext context}) async {
    try {
      // Create user with email and password
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Get the current Firebase user
      User? user = userCredential.user;

      // If the user is created successfully, save the username to Firestore
      if (user != null) {
        final userModel =
        UserModel(username: username, email: email, password: password);
        final userService = UserService();
        await userService
            .createUser(userModel); // Save user to your custom database

        // Navigate to Home after successful registration
        await Future.delayed(const Duration(seconds: 1));
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (BuildContext context) => const Home()));
      }
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
        message = 'Something went wrong while signing you up.';
        print('Something went wrong during signup');
      }

      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
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
    }
  }

  Future<void> signout({required BuildContext context}) async {
    GoogleSignIn googleSignIn = GoogleSignIn();
    googleSignIn.disconnect();
    await FirebaseAuth.instance.signOut();
    await Future.delayed(const Duration(seconds: 1));
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (BuildContext context) => Home()));
  }
}
