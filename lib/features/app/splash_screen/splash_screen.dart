import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/pages/login_page.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/pages/main_menu.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/pages/settings_page.dart';
import 'package:flutter_app_5s/main.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app_5s/utils/common.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  /* @override
  void initState() {
    super.initState();
    _redirect();
  }*/

  User? _user;

@override
void initState() {
  super.initState();
  _getAuth();
}

Future<void> _getAuth() async {
  if (mounted) {
    setState(() {
      _user = client.auth.currentUser;
    });
  }
  client.auth.onAuthStateChange.listen((event) {
    if (mounted) {
      setState(() {
        _user = event.session?.user;
      });
    }
  });
}


 

  /* @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(134, 75, 111, 1),
      body: Center(
        child: Column(
          children: [
            const Expanded(child: SizedBox(), flex: 2,),
            Expanded(
              flex: 1,
              child: Image.file(File('lib/assets/images/app_logo.png')),
            ),
            // _LoadingText(),
            const Expanded(child: SizedBox(), flex: 2,),
          ],
        ),
      ),
    );
  }*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _user == null ? const LoginPage() : const MainMenu(),
    );
  }
}
/*
class _LoadingText extends StatefulWidget {
  @override
  __LoadingTextState createState() => __LoadingTextState();
}

class __LoadingTextState extends State<_LoadingText> {
  late Timer _timer;
  int _index = 0;
  final List<String> _texts = ['Cargando', 'Cargando.', 'Cargando..', 'Cargando...'];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      setState(() {
        _index = (_index + 1) % _texts.length;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _texts[_index],
      style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.w600),
    );
  }
}
*/