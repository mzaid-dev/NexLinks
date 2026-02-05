class AppValidators {
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    if (value.length > 20) {
      return 'Username must be less than 20 characters';
    }
    if (!RegExp(r'^[a-z0-9._]+$').hasMatch(value)) {
      return 'Username can only contain lowercase letters, numbers, dots, and underscores';
    }
    return null;
  }

  static String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 2) {
      return 'Please enter a valid full name';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Full name can only contain letters and spaces';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  static String? validateBio(String? value) {
    if (value != null && value.length > 150) {
      return 'Bio must be less than 150 characters';
    }
    return null;
  }

  static String? validateRole(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    if (value.length < 2) {
      return 'Please enter a valid role';
    }
    return null;
  }

  static String? validateExperience(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final years = int.tryParse(value);
    if (years == null) {
      return 'Please enter a valid number';
    }
    if (years < 0 || years > 50) {
      return 'Please enter a realistic number of years (0-50)';
    }
    return null;
  }
}
