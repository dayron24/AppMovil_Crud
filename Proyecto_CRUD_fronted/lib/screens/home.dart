import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/cursos');
              },
              child: const Text('Ver cursos'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/estudiantes');
              },
              child: const Text('Ver estudiantes'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/estudiantesXcurso');
              },
              child: const Text('Ver estudiantes por curso'),
            ),
          ],
        ),
      ),
    );
  }
}
