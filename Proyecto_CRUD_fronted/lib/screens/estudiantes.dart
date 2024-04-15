import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
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



class EstudiantesScreen extends StatefulWidget {
  const EstudiantesScreen({super.key});

  @override
  _EstudiantesScreenState createState() => _EstudiantesScreenState();
}

class _EstudiantesScreenState extends State<EstudiantesScreen> {

  @override
  void initState() {
    super.initState();
    // Conectar a la base de datos al iniciar la pantalla

    // Llama a cargarEstudiantes después de que la conexión se haya establecido
    cargarEstudiantes();

  }
  List<Estudiante> estudiantes = [];

  Future<void> cargarEstudiantes() async {
    print("Cargando estudiantes...");
    final response = await http.get(Uri.parse('http://localhost:8000/get-estudiantes'));

    if (response.statusCode == 200) {
      final List<dynamic> estudiantesJson = jsonDecode(response.body);

      final List<Estudiante> estudiantesList = estudiantesJson.map((estudianteJson) {
        return Estudiante(
          nombreCompleto: estudianteJson['nombreCompleto'],
          carnet: estudianteJson['carnet'],
          numeroCelular: estudianteJson['numeroCelular'],
          correo: estudianteJson['correo'],
          carrera: estudianteJson['carrera'],
          fechaNacimiento: estudianteJson['fechaNacimiento'],
        );
      }).toList();

      setState(() {
        estudiantes = estudiantesList;
      });
      print(estudiantes);
    } else {
      throw Exception('Fallo al cargar los estudiantes');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estudiantes'),
      ),
      body: ListView.builder(
        itemCount: estudiantes.length,
        itemBuilder: (BuildContext context, int index) {
          final estudiante = estudiantes[index];
          return ListTile(
            title: Text(estudiante.nombreCompleto),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Carnet: ${estudiante.carnet.toString()}'),
                Text('Celular: ${estudiante.numeroCelular}'),
                Text('Correo: ${estudiante.correo}'),
                Text('Fecha de Nacimiento: ${estudiante.fechaNacimiento}'),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                mostrarFormularioEditarEstudiante(context, estudiante);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _mostrarFormularioNuevoEstudiante(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
  void mostrarFormularioEditarEstudiante(BuildContext context, Estudiante estudiante) {
    TextEditingController nombreController = TextEditingController(text: estudiante.nombreCompleto);
    TextEditingController celularController = TextEditingController(text: estudiante.numeroCelular);
    TextEditingController correoController = TextEditingController(text: estudiante.correo);
    TextEditingController carreraController = TextEditingController(text: estudiante.carrera);
    TextEditingController fechaNacimientoController = TextEditingController(text: estudiante.fechaNacimiento);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Estudiante'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre Completo'),
                ),
                TextField(
                  controller: celularController,
                  decoration: const InputDecoration(labelText: 'Número Celular'),
                ),
                TextField(
                  controller: correoController,
                  decoration: const InputDecoration(labelText: 'Correo'),
                ),
                TextField(
                  controller: carreraController,
                  decoration: const InputDecoration(labelText: 'Carrera'),
                ),
                TextField(
                  controller: fechaNacimientoController,
                  decoration: const InputDecoration(labelText: 'Fecha de Nacimiento'),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red), // Icono de basurero
              onPressed: () {
                eliminarEstudiante(context, estudiante);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              onPressed: () {
                _guardarCambiosEstudiante(
                  context,
                  estudiante,
                  nombreController.text,
                  celularController.text,
                  correoController.text,
                  carreraController.text,
                  fechaNacimientoController.text,
                );
                Navigator.of(context).pop();
              },
              child: const Text('Guardar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  void eliminarEstudiante(context,Estudiante estudiante)
    async {
      try {
        final url = Uri.parse('http://localhost:8000/eliminar-estudiante/${estudiante.carnet}');
        final response = await http.delete(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({

          }),
        );

        if (response.statusCode == 200) {
          print('Estudiante eliminado correctamente en la base de datos.');
          setState(() {
            cargarEstudiantes();
          });
        } else {
          print('Error al eliminar el estudiante en la base de datos: ${response.statusCode}');
        }
      } catch (e) {
        print('Error al eliminar el estudiante en la base de datos: $e');
      }
  }

  void _guardarCambiosEstudiante(context,
      Estudiante estudiante,
      String nuevoNombre,

      String nuevoCelular,
      String nuevoCorreo,
      String nuevaCarrera,
      String nuevaFechaNacimiento) async {
    try {
      final url = Uri.parse('http://localhost:8000/actualizar-estudiante/${estudiante.carnet}');
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({

          'nombreCompleto': nuevoNombre,
          'numeroCelular': nuevoCelular,
          'correo': nuevoCorreo,
          'carrera': nuevaCarrera,
          'fechaNacimiento': nuevaFechaNacimiento,
        }),
      );

      if (response.statusCode == 200) {
        print('Estudiante actualizado correctamente en la base de datos.');
        setState(() {
          cargarEstudiantes();
        });
      } else {
        print('Error al actualizar el estudiante en la base de datos: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al actualizar el estudiante en la base de datos: $e');
    }
  }


  void _mostrarFormularioNuevoEstudiante(BuildContext context) {
    TextEditingController nombreController = TextEditingController();
    TextEditingController carnetController = TextEditingController();
    TextEditingController celularController = TextEditingController();
    TextEditingController correoController = TextEditingController();
    TextEditingController carreraController = TextEditingController();
    TextEditingController fechaNacimientoController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Crear Nuevo Estudiante'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre Completo'),
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  controller: carnetController,
                  decoration: const InputDecoration(labelText: 'Carnet'),
                ),
                TextField(
                  controller: celularController,
                  decoration: const InputDecoration(labelText: 'Número Celular'),
                ),
                TextField(
                  controller: correoController,
                  decoration: const InputDecoration(labelText: 'Correo'),
                ),
                TextField(
                  controller: carreraController,
                  decoration: const InputDecoration(labelText: 'Carrera'),
                ),
                TextField(
                  controller: fechaNacimientoController,
                  decoration:
                  const InputDecoration(labelText: 'Fecha de Nacimiento'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _guardarNuevoEstudiante(
                  nombreController.text,
                  int.parse(carnetController.text),
                  celularController.text,
                  correoController.text,
                  carreraController.text,
                  fechaNacimientoController.text,
                );
                Navigator.of(context).pop();
              },
              child: const Text('Guardar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  void _guardarNuevoEstudiante(
      String nombre,
      int carnet,
      String celular,
      String correo,
      String carrera,
      String fechaNacimiento,
      ) async {
    try {
      final url = Uri.parse('http://localhost:8000/ingresar-estudiante');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'carnet': carnet,
          'nombreCompleto': nombre,
          'numeroCelular': celular,
          'correo': correo,
          'carrera': carrera,
          'fechaNacimiento': fechaNacimiento,
        }),
      );

      if (response.statusCode == 201) {
        print('Estudiante guardado correctamente en la base de datos.');
        setState(() {
          cargarEstudiantes();
        });
      } else {
        print('Error al guardar el estudiante en la base de datos: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al guardar el estudiante en la base de datos: $e');
    }
  }

}