import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
class AuthHelper{
final FirebaseAuth _auth =FirebaseAuth.instance;
get  uesr => _auth.currentUser;
Future<User?> signInWithGoogle()async{
  try {
    final signIn = GoogleSignIn.instance;
    final user = await signIn.authenticate();
    final auth = await user.authentication;

    final credential = GoogleAuthProvider.credential(
      idToken: auth.idToken,
    );
    final result =
    await FirebaseAuth.instance.signInWithCredential(credential);

    return result.user;

  } catch (e) {
    print("خطأ تسجيل الدخول بجوجل: $e");
    return null;
  }
}
Future<String?>  signUp({required String userName,required String email,required String password})async{
  try{
    await _auth.createUserWithEmailAndPassword(email: email, password: password);
    User? user = FirebaseAuth.instance.currentUser;
    await user?.updateDisplayName(userName);
    await user?.reload();
    return null;
  } on FirebaseException catch(e){
    return e.message;
  }
}
Future<String?>  signIn({required String email,required String password})async{
  try{
    await _auth.signInWithEmailAndPassword(email: email, password: password);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('logged_in', true);
    return null;
  } on FirebaseException catch(e){
    return e.message;
  }
}
Future<String?>  signOut()async{

    await _auth.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('logged_in', false);

}
}