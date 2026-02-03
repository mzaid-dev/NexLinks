import 'package:firebase_auth/firebase_auth.dart';
import 'package:nexlinks/core/services/logger_service.dart';
import 'dart:io';
import 'package:flutter/services.dart';

class ErrorHandler {
  static String getMessage(dynamic error) {
    LoggerService.error("Captured Error: $error");
    
    if (error is SocketException) {
      return "Oops! It looks like you're offline. Please check your internet connection and try again.";
    }
    
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return "We couldn't find an account with that email. Maybe try signing up?";
        case 'wrong-password':
          return "That password doesn't seem right. Give it another shot!";
        case 'network-request-failed':
          return "Connection lost. Please make sure you have a working internet connection.";
        case 'email-already-in-use':
          return "This email is already registered. Try logging in instead!";
        case 'invalid-credential':
          return "Invalid credentials. Please check your login details.";
        case 'too-many-requests':
           return "Whoa, slow down! Too many attempts. Please try again later.";
        default:
          return error.message ?? "Something went wrong. Let's try that again.";
      }
    }

    if (error is PlatformException) {
      // Google Sign In often throws PlatformException
      if (error.code == 'sign_in_canceled') {
        return "Sign in cancelled.";
      }
      if (error.code == 'network_error') {
         return "Network error. Please check your connection.";
      }
      return error.message ?? "An error occurred with the service.";
    }

    if (error is FirebaseException) {
      return "We're having trouble reaching our servers. Please try again in a moment.";
    }

    if (error is Exception) {
      String msg = error.toString().replaceAll("Exception: ", "").trim();
      return msg.isNotEmpty ? msg : "Something unexpected happened. We're looking into it!";
    }

    return "Oops! Something went wrong on our end. Please try again soon.";
  }
}
