import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';
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


class EstudiantesWidget extends StatefulWidget {
  final String codigo;
  final String nombreCompleto;
  const EstudiantesWidget({super.key, required this.codigo,required this.nombreCompleto});

  @override
  _EstudiantesWidgetState createState() => _EstudiantesWidgetState();
}

class _EstudiantesWidgetState extends State<EstudiantesWidget> {
  List<Estudiante> estudiantesList = [];

  @override
  void initState() {
    super.initState();
    cargarEstudiantes(widget.codigo);
  }



  Future<void> cargarEstudiantes(String codigo) async {
    print("Cargando estudiantes...");
    final response = await http.get(Uri.parse('http://localhost:8000/get-estudiantesXCursos/$codigo'));

    if (response.statusCode == 200) {
      if (jsonDecode(response.body) != null) {
        final List<dynamic> estudiantesJson = jsonDecode(response.body);
        setState(() {

          estudiantesList = estudiantesJson.map((estudianteJson) {
            return Estudiante(
              nombreCompleto: estudianteJson['nombreCompleto'],
              carnet: estudianteJson['carnet'],
              numeroCelular: estudianteJson['numeroCelular'],
              correo: estudianteJson['correo'],
              carrera: estudianteJson['carrera'],
              fechaNacimiento: estudianteJson['fechaNacimiento'],
            );
          }).toList();
        });
      }
      else{
        setState(() {

          estudiantesList = [];
        });
      }
    } else {
      estudiantesList = [];
      throw Exception('Fallo al cargar los estudiantes');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Estudiantes de ${widget.nombreCompleto}'),
      ),
      body: Container(
        color: Colors.white, // Establecer el color de fondo blanco
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estudiantes de ${widget.nombreCompleto}',
              style: const TextStyle(
                color: Colors.black, // Establecer el color del texto a negro
                fontSize: 20.0, // Tamaño del texto
                fontWeight: FontWeight.bold, // Peso del texto
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded( // Usar Expanded para permitir que el ListView.builder se expanda
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: estudiantesList.length,
                itemBuilder: (BuildContext context, int index) {
                  final Estudiante estudiante = estudiantesList[index];
                  return ListTile(
                    title: Text(estudiante.nombreCompleto),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        eliminarEstudianteDeCurso(context, estudiante, widget.codigo);
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    _mostrarEstudiantesPorAgregar(context, widget.codigo);
                  },
                  child: const Text(
                    'Añadir nuevo estudiante',
                    style: TextStyle(
                      color: Colors.black, // Establecer el color del texto a negro
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Cerrar',
                    style: TextStyle(
                      color: Colors.black, // Establecer el color del texto a negro
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }



  Future<void> _mostrarEstudiantesPorAgregar(BuildContext context, String codigo) async {
    final response = await http.get(Uri.parse('http://localhost:8000/get-estudiantes-NO-en-curso/$codigo'));

    if (response.statusCode == 200) {
      if (jsonDecode(response.body) != null) {
        final List<dynamic> estudiantesJson = jsonDecode(response.body);
        List<Estudiante> estudiantesList = estudiantesJson.map((
            estudianteJson) {
          return Estudiante(
            nombreCompleto: estudianteJson['nombreCompleto'],
            carnet: estudianteJson['carnet'],
            numeroCelular: estudianteJson['numeroCelular'],
            correo: estudianteJson['correo'],
            carrera: estudianteJson['carrera'],
            fechaNacimiento: estudianteJson['fechaNacimiento'],
          );
        }).toList();

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              //key: dialogKey,
              title: Text('Agregar estudiantes a ${widget.nombreCompleto}'),
              content: SingleChildScrollView(
                child: Column(
                  children: estudiantesList.map((estudiante) {
                    return ListTile(
                      title: Text(estudiante.nombreCompleto),
                      trailing: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          agregarEstudianteAcurso( estudiante.carnet, codigo);

                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cerrar'),
                ),
              ],
            );
          },
        );
      }
      else{

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              //key: dialogKey,
              title: Text('Agregar estudiantes a ${widget.nombreCompleto}'),
              content: SingleChildScrollView(
                child: Column(
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cerrar'),
                ),
              ],
            );
          },
        );
      }


    }
  }

  Future<void> agregarEstudianteAcurso( int carnetEstudiante, String codigoCurso) async {
    final url = Uri.parse('http://localhost:8000/ingresar-estudianteXCurso');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'carnetEstudiante': carnetEstudiante,
        'codigoCurso': codigoCurso,
      }),
    );

    if (response.statusCode == 201) {
      print('Registro ingresado en EstudiantesXCurso');
      cargarEstudiantes(codigoCurso);

    } else {
      throw Exception('Fallo al ingresar el registro en EstudiantesXCurso');
    }
  }


  Future<void> eliminarEstudianteDeCurso(BuildContext context, Estudiante estudiante, codigo) async {
    try {
      final url = Uri.parse('http://localhost:8000/borrar-estudianteXCurso:codigoCurso/$codigo/${estudiante.carnet}');
      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({}),
      );

      if (response.statusCode == 200) {

        print('Estudiante eliminado correctamente en la base de datos.');
        cargarEstudiantes(codigo);
      } else {
        print('Error al eliminar el estudiante en la base de datos: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al eliminar el estudiante en la base de datos: $e');
    }
  }
}

