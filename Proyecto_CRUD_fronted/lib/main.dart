import 'package:flutter/material.dart';
import 'package:proyecto_crud/screens/cursos.dart';
import 'package:proyecto_crud/screens/estudiantes.dart';
import 'package:proyecto_crud/screens/estudiantesXcurso.dart';

import 'screens/home.dart';

void main() {
  runApp(const MyApp());
}
class Curso {
  String nombreCompleto;
  String codigo;
  String escuela;
  String modalidad;
  int creditos;

  Curso({
    required this.nombreCompleto,
    required this.codigo,
    required this.creditos,
    required this.escuela,
    required this.modalidad,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/cursos': (context) => const CursosScreen(),
        '/estudiantes': (context) => const EstudiantesScreen(),
        '/estudiantesXcurso': (context) => const EstudiantesPorCursoScreen(),

      },
    );
  }
}