import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
  final User? user;

  AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
    this.user,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    User? user,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      user: user ?? this.user,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthNotifier(this._firebaseAuth, this._googleSignIn) : super(AuthState()) {
    _initialize();
  }

  // Initialize and listen to auth events
  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);

    try {
      // Initialize Google Sign-In (required for v7.x)
      await _googleSignIn.initialize();

      // Listen to Google Sign-In authentication events
      _googleSignIn.authenticationEvents.listen((event) {
        switch (event) {
          case GoogleSignInAuthenticationEventSignIn():
            _handleGoogleSignInEvent(event.user);
            break;
          case GoogleSignInAuthenticationEventSignOut():
            state = state.copyWith(isAuthenticated: false, user: null);
            break;
          default:
            break;
        }
      });

      // Listen to Firebase auth state changes
      _firebaseAuth.authStateChanges().listen((User? user) {
        state = state.copyWith(isAuthenticated: user != null, user: user);
      });

      // Check current auth status
      await _checkAuthStatus();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> _checkAuthStatus() async {
    try {
      final user = _firebaseAuth.currentUser;
      state = state.copyWith(
        isAuthenticated: user != null,
        user: user,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Handle Google Sign-In event
  Future<void> _handleGoogleSignInEvent(GoogleSignInAccount googleUser) async {
    try {
      // Get authentication details (synchronous in v7)
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // Create Firebase credential (only idToken is needed)
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      await _firebaseAuth.signInWithCredential(credential);
    } catch (e) {
      state = state.copyWith(error: 'Failed to sign in with Google: $e');
    }
  }

  // Email/Password Sign Up
  Future<void> signUpWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      state = state.copyWith(
        isAuthenticated: true,
        user: userCredential.user,
        isLoading: false,
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Sign up failed';
      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'An account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is invalid.';
      }
      state = state.copyWith(isLoading: false, error: errorMessage);
      throw Exception(errorMessage);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      throw e;
    }
  }

  // Email/Password Sign In
  Future<void> signInWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      state = state.copyWith(
        isAuthenticated: true,
        user: userCredential.user,
        isLoading: false,
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Sign in failed';
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password provided.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is invalid.';
      } else if (e.code == 'user-disabled') {
        errorMessage = 'This user account has been disabled.';
      } else if (e.code == 'invalid-credential') {
        errorMessage = 'The credentials provided are invalid.';
      }
      state = state.copyWith(isLoading: false, error: errorMessage);
      throw Exception(errorMessage);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      throw e;
    }
  }

  // Google Sign In - CORRECT FOR google_sign_in ^7.2.0
  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Check if platform supports authenticate method
      if (!_googleSignIn.supportsAuthenticate()) {
        throw Exception('This platform does not support Google Sign-In');
      }

      // Trigger the authentication flow
      // This will emit events that are handled by the listener
      await _googleSignIn.authenticate();

      state = state.copyWith(isLoading: false);
    } on GoogleSignInException catch (e) {
      String errorMessage = 'Google sign in failed';
      if (e.code == 'sign_in_canceled') {
        errorMessage = 'Sign in was canceled';
      } else if (e.code == 'sign_in_failed') {
        errorMessage = 'Sign in failed. Please try again.';
      } else if (e.code == 'network_error') {
        errorMessage = 'Network error. Please check your connection.';
      } else {
        errorMessage = '${e.code}: ${e.description}';
      }
      state = state.copyWith(isLoading: false, error: errorMessage);
      throw Exception(errorMessage);
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Firebase authentication failed';
      if (e.code == 'account-exists-with-different-credential') {
        errorMessage =
            'An account already exists with the same email address but different sign-in credentials.';
      } else if (e.code == 'invalid-credential') {
        errorMessage = 'The credential is malformed or has expired.';
      } else if (e.code == 'operation-not-allowed') {
        errorMessage =
            'Google sign-in is not enabled. Please enable it in Firebase Console.';
      } else if (e.code == 'user-disabled') {
        errorMessage = 'This user account has been disabled.';
      }
      state = state.copyWith(isLoading: false, error: errorMessage);
      throw Exception(errorMessage);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Google sign in failed: ${e.toString()}',
      );
      throw e;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await Future.wait([_firebaseAuth.signOut(), _googleSignIn.signOut()]);

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      state = AuthState();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

// Providers
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  // Use GoogleSignIn.instance (singleton) for v7.x
  return GoogleSignIn.instance;
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  final googleSignIn = ref.watch(googleSignInProvider);
  return AuthNotifier(firebaseAuth, googleSignIn);
});
