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
  // final GoogleSignIn _googleSignIn;

  // AuthNotifier(this._firebaseAuth, this._googleSignIn) : super(AuthState()) {
  //   _checkAuthStatus();

  //   // Listen to auth state changes
  //   _firebaseAuth.authStateChanges().listen((User? user) {
  //     state = state.copyWith(isAuthenticated: user != null, user: user);
  //   });
  // }
  AuthNotifier(this._firebaseAuth) : super(AuthState()) {
    _checkAuthStatus();

    // Listen to auth state changes
    _firebaseAuth.authStateChanges().listen((User? user) {
      state = state.copyWith(isAuthenticated: user != null, user: user);
    });
  }

  Future<void> _checkAuthStatus() async {
    state = state.copyWith(isLoading: true);
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

  // Google Sign In
  // Future<void> signInWithGoogle() async {
  //   state = state.copyWith(isLoading: true, error: null);

  //   try {
  //     // Trigger Google Sign In flow
  //     final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

  //     if (googleUser == null) {
  //       // User canceled the sign-in
  //       state = state.copyWith(isLoading: false);
  //       return;
  //     }

  //     // Get auth tokens
  //     final GoogleSignInAuthentication googleAuth =
  //         await googleUser.authentication;

  //     // Create Firebase credential
  //     final credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );

  //     // Firebase Sign In
  //     final userCredential = await _firebaseAuth.signInWithCredential(
  //       credential,
  //     );

  //     state = state.copyWith(
  //       isAuthenticated: true,
  //       user: userCredential.user,
  //       isLoading: false,
  //     );
  //   } catch (e) {
  //     state = state.copyWith(
  //       isLoading: false,
  //       error: 'Google sign in failed: $e',
  //     );
  //     throw e;
  //   }
  // }

  // Sign Out
  Future<void> signOut() async {
    try {
      // await Future.wait([_firebaseAuth.signOut(), _googleSignIn.signOut()]);
      await _firebaseAuth.signOut();
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

// final googleSignInProvider = Provider<GoogleSignIn>((ref) {
//   return GoogleSignIn(scopes: ['email']);
// });

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  // final googleSignIn = ref.watch(googleSignInProvider);
  // return AuthNotifier(firebaseAuth, googleSignIn);
  return AuthNotifier(firebaseAuth);
});


// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../providers/auth_provider.dart';

// class HomePage extends ConsumerWidget {
//   const HomePage({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final authState = ref.watch(authProvider);
//     final user = authState.user;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Home'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: () async {
//               await ref.read(authProvider.notifier).signOut();
//             },
//           ),
//         ],
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text(
//               'Welcome!',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 16),
//             if (user?.email != null)
//               Text(
//                 'Email: ${user!.email}',
//                 style: const TextStyle(fontSize: 18),
//               ),
//             const SizedBox(height: 8),
//             if (user?.displayName != null)
//               Text(
//                 'Name: ${user!.displayName}',
//                 style: const TextStyle(fontSize: 18),
//               ),
//             const SizedBox(height: 8),
//             if (user?.uid != null)
//               Text(
//                 'User ID: ${user!.uid}',
//                 style: const TextStyle(fontSize: 14, color: Colors.grey),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// ============================================
// SETUP INSTRUCTIONS
// ============================================
/*
1. Add dependencies to pubspec.yaml:
   dependencies:
     firebase_core: ^2.24.2
     firebase_auth: ^4.15.3
     google_sign_in: ^6.1.6
     shared_preferences: ^2.2.2
     flutter_riverpod: ^2.4.9

2. Install FlutterFire CLI:
   dart pub global activate flutterfire_cli

3. Configure Firebase for your project:
   flutterfire configure

4. For Google Sign-In:
   - Android: SHA-1 fingerprint is automatically configured by flutterfire
   - iOS: Add URL scheme in Info.plist (done automatically by flutterfire)
   - Enable Google Sign-In in Firebase Console

5. Run the app!
*/