import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:proyecto_crud/screens/estudiantesEnXCurso.dart';

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

class Estudiante {
  String nombreCompleto;
  int carnet;
  String numeroCelular;
  String correo;
  String carrera;
  String fechaNacimiento;

  Estudiante({
    required this.nombreCompleto,
    required this.carnet,
    required this.numeroCelular,
    required this.correo,
    required this.carrera,
    required this.fechaNacimiento,
  });
}

class EstudiantesPorCursoScreen extends StatefulWidget {
  const EstudiantesPorCursoScreen({super.key});

  @override
  _EstudiantesPorCursoScreenState createState() => _EstudiantesPorCursoScreenState();
}

class _EstudiantesPorCursoScreenState extends State<EstudiantesPorCursoScreen> {


  List<Curso> cursos = [];

  @override
  void initState() {
    super.initState();
    cargarCursos();
  }
  @override
  Widget build(BuildContext context) {
    if (cursos.isEmpty) {
      // Si cursos está vacío, muestra un indicador de carga o un mensaje de espera
      return const Center(
        child: CircularProgressIndicator(), // O cualquier otro widget de carga
      );
    } else {
      // Si cursos contiene datos, construye la lista normalmente
      return Scaffold(
        appBar: AppBar(
          title: const Text('Estudiantes por cursos'),
        ),
        body: ListView.builder(
          itemCount: cursos.length,
          itemBuilder: (BuildContext context, int index) {
            final Curso curso = cursos[index];
            return ListTile(
              title: Text(curso.nombreCompleto),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Carnet: ${curso.codigo}'),
                  Text('Escuela: ${curso.escuela}'),
                  Text('Creditos: ${curso.creditos}'),
                  Text('Modalidad: ${curso.modalidad}'),
                ],
              ),
              trailing: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EstudiantesWidget(nombreCompleto: curso.nombreCompleto, codigo: curso.codigo),
                    ),
                  );
                },
                child: const Text('Ver Estudiantes\n de este curso'),
              ),
            );
          },
        ),
      );
    }
  }

  Future<void> cargarCursos() async {
    print("Cargando cursos...");
    final response = await http.get(
        Uri.parse('http://localhost:8000/get-cursos'));

    if (response.statusCode == 200) {
      final List<dynamic> cursosJson = jsonDecode(response.body);

      final List<Curso> cursosList = cursosJson.map((cursoJson) {
        return Curso(
          codigo: cursoJson['codigo'],
          nombreCompleto: cursoJson['nombreCompleto'],
          escuela: cursoJson['escuela'],
          modalidad: cursoJson['modalidad'],
          creditos: cursoJson['creditos'],
        );
      }).toList();

      setState(() {
        cursos = cursosList;
      });
    } else {
      throw Exception('Fallo al cargar los cursos');
    }
  }

}
