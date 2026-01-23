// TODO Implement this library.
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      // case TargetPlatform.macOS:
      //   return macos;
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "1:403935387560:android:4e1b88c51801716665879d",
    appId: "YOUR_ANDROID_APP_ID",
    messagingSenderId: "403935387560",
    projectId: "pinterest-clone-fc4c9",
    storageBucket: "pinterest-clone-fc4c9.appspot.com",
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "AIzaSyBKOAVA3PH923h5C3Uu0DLNdc2zOcpXbf0",
    appId: "1:403935387560:ios:6f5ad27867eda62065879d",
    messagingSenderId: "403935387560",
    projectId: "pinterest-clone-fc4c9",
    storageBucket: "pinterest-clone-fc4c9.appspot.com",
    iosBundleId: "com.example.pinterest",
  );

  // static const FirebaseOptions macos = FirebaseOptions(
  //   apiKey: "YOUR_MACOS_API_KEY",
  //   appId: "YOUR_MACOS_APP_ID",
  //   messagingSenderId: "403935387560",
  //   projectId: "pinterest-clone-fc4c9",
  //   storageBucket: "pinterest-clone-fc4c9.appspot.com",
  // );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: "AIzaSyCIuFLVsPU-OTMIeWyrgElc6GqAjYf7Kmg",
    authDomain: "pinterest-clone-fc4c9.firebaseapp.com",
    projectId: "pinterest-clone-fc4c9",
    storageBucket: "pinterest-clone-fc4c9.firebasestorage.app",
    messagingSenderId: "403935387560",
    appId: "1:403935387560:web:980400dfe4b3dbb465879d",
    measurementId: "G-4ENC0QZHJ4",
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyCIuFLVsPU-OTMIeWyrgElc6GqAjYf7Kmg",
    authDomain: "pinterest-clone-fc4c9.firebaseapp.com",
    projectId: "pinterest-clone-fc4c9",
    storageBucket: "pinterest-clone-fc4c9.firebasestorage.app",
    messagingSenderId: "403935387560",
    appId: "1:403935387560:web:800bdef197e2e36165879d",
    measurementId: "G-KTKN6B3EK8",
  );
}
