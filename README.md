# hdse_application

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
#   h d s e _ a p p l i c a t i o n 
 
 

gen release jks file (pass: 834677)
    keytool -genkey -v -keystore c:\Users\Chanin\hdse-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
  gen Release Key
  keytool -exportcert -alias hdse -keystore "C:\Users\Chanin\hdse-keystore.jks" | C:\OpenSSL\bin\openssl sha1 -binary | C:\OpenSSL\bin\openssl base64
  gen Debug Key
  keytool -exportcert -alias androiddebugkey -keystore "C:\Users\Chanin\.android\debug.keystore" | C:\OpenSSL\bin\openssl sha1 -binary | C:\OpenSSL\bin\openssl base64
  keytool -exportcert -list -v \ -alias upload -keystore C:\Users\Chanin\hdse-keystore.jks
  gen certificate fingerprint
  keytool -list -v -alias upload -keystore C:\Users\Chanin\hdse-keystore.jks
  keytool -list -v -alias androiddebugkey -keystore C:\Users\Chanin\.android\debug.keystore
