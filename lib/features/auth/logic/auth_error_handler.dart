import 'package:firebase_auth/firebase_auth.dart';

class AuthErrorHandler {
  static String getErrorMessage(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'This email is already registered. Please login instead.';
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'operation-not-allowed':
          return 'Email/password accounts are not enabled.';
        case 'weak-password':
          return 'Your password is too weak. Please use a stronger password.';
        case 'user-disabled':
          return 'This account has been disabled. Please contact support.';
        case 'user-not-found':
          return 'No account found with this email.';
        case 'wrong-password':
          return 'Incorrect password. Please try again.';
        case 'invalid-credential':
          return 'Invalid credentials. Please try again.';
        case 'network-request-failed':
          return 'Network error. Please check your internet connection.'; 
        default:
          return 'Authentication failed: ${error.message ?? "Unknown error"}';
      }
    } else if (error is String) {
      return error; // Already a string message
    } else {
      // General exceptions or others
      final String msg = error.toString();
      if (msg.contains("check username")) {
        return "Unable to verify username availability. Please check your connection.";
      }
      if (msg.contains("network") || msg.contains("connection")) {
         return "Network error. Please check your internet connection.";
      }
      return "Something went wrong. Please try again.";
    }
  }
}
