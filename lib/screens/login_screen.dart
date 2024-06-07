import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mi_app_flutter/screens/home_screen.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _passwordController = TextEditingController();
  final Map<String, String> _correctPasswords = {
    '12345678': 'Daniel',
    '0000': 'Andres',
    '1234': 'David'
  };
  String _errorMessage = '';

  void _login(BuildContext context) {
    String enteredPassword = _passwordController.text;
    if (_correctPasswords.containsKey(enteredPassword)) {
      String name = _correctPasswords[enteredPassword]!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bienvenido $name'),
          duration: Duration(seconds: 2),
        ),
      );

      // Actualiza la contraseña del usuario actual
      // (suponiendo que tengas una variable de usuario actual)
      String currentUserPassword = enteredPassword;

      // Navega a la pantalla HomeScreen y pasa la nueva contraseña
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(userPassword: currentUserPassword),
        ),
      );
    } else {
      setState(() {
        _errorMessage = 'Contraseña incorrecta. Inténtalo de nuevo.';
      });
      _passwordController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenido a ContAppble'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Guarda tus datos a la mano',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                errorText: _errorMessage.isEmpty ? null : _errorMessage,
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _login(context),
              child: Text('Iniciar Sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
