import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

class CursosScreen extends StatefulWidget {
  const CursosScreen({super.key});

  @override
  _CursosScreenState createState() => _CursosScreenState();
}

class _CursosScreenState extends State<CursosScreen> {
  @override
  void initState() {
    super.initState();
    // Conectar a la base de datos al iniciar la pantalla

    // Llama a cargarEstudiantes después de que la conexión se haya establecido
    cargarCursos();

  }
  List<Curso> cursos = [];

  Future<void> cargarCursos() async {
    print("Cargando cursos...");
    final response = await http.get(Uri.parse('http://localhost:8000/get-cursos'));

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
      print(cursos);
    } else {
      throw Exception('Fallo al cargar los cursos');
    }
  }

  void mostrarFormularioEditarCurso(
      context, Curso Curso) {
    TextEditingController nombreController =
    TextEditingController(text: Curso.nombreCompleto);

    TextEditingController codigoController =
    TextEditingController(text: Curso.codigo);

    TextEditingController creditosController =
    TextEditingController(text: Curso.creditos.toString());

    TextEditingController modalidadController =
    TextEditingController(text: Curso.modalidad);

    TextEditingController escuelaController =
    TextEditingController(text: Curso.escuela);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Curso'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre Completo'),
                ),
                TextField(
                  controller: codigoController,
                  decoration: const InputDecoration(labelText: 'Codigo'),
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  controller: creditosController,
                  decoration: const InputDecoration(labelText: 'Creditos'),
                ),
                TextField(
                  controller: modalidadController,
                  decoration: const InputDecoration(labelText: 'Modalidad'),
                ),
                TextField(
                  controller: escuelaController,
                  decoration: const InputDecoration(labelText: 'Escuela'),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red), // Icono de basurero
              onPressed: () {
                eliminarCurso(context, Curso);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              onPressed: () {
                _guardarCambiosCurso(
                  context,
                  Curso,
                  nombreController.text,
                  codigoController.text,
                  modalidadController.text,
                  escuelaController.text,
                  int.parse(creditosController.text,)

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

  void eliminarCurso(context,Curso curso)
    async {
      try {
        final url = Uri.parse('http://localhost:8000/eliminar-curso/${curso.codigo}');
        final response = await http.delete(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({

          }),
        );

        if (response.statusCode == 200) {
          print('Curso eliminado correctamente en la base de datos.');
          setState(() {
            cargarCursos();
          });
        } else {
          print('Error al eliminar el curso en la base de datos: ${response.statusCode}');
        }
      } catch (e) {
        print('Error al eliminar el curso en la base de datos: $e');
      }
  }
  void _guardarCambiosCurso(
      context,
      Curso curso,
      String nuevoNombre,
      String nuevoCodigo,
      String nuevaModalidad,
      String nuevaEscuela,
      int nuevoCreditos) async {
    try {
      final url = Uri.parse('http://localhost:8000/actualizar-curso/${curso.codigo}');
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({

          'nombreCompleto': nuevoNombre,
          'escuela': nuevaEscuela,
          'modalidad': nuevaModalidad,
          'creditos': nuevoCreditos,

        }),
      );

      if (response.statusCode == 200) {
        print('curso actualizado correctamente en la base de datos.');
        setState(() {
          cargarCursos();
        });
      } else {
        print('Error al actualizar el curso en la base de datos: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al actualizar el curso en la base de datos: $e');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cursos'),
      ),
      body: ListView.builder(
        itemCount: cursos.length,
        itemBuilder: (BuildContext context, int index) {
          final Curso = cursos[index];
          return ListTile(
            title: Text(Curso.nombreCompleto),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Carnet: ${Curso.codigo}'),
                Text('Escuela: ${Curso.escuela}'),
                Text('Creditos: ${Curso.creditos}'),
                Text('Modalidad: ${Curso.modalidad}'),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                mostrarFormularioEditarCurso(context, Curso);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _mostrarFormularioNuevoCurso(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _mostrarFormularioNuevoCurso(BuildContext context) {
    TextEditingController nombreController = TextEditingController();
    TextEditingController creditosController = TextEditingController();
    TextEditingController escuelaController = TextEditingController();
    TextEditingController codigoController = TextEditingController();
    TextEditingController modalidadController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Crear Nuevo Curso'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre Completo'),
                ),
                TextField(
                  controller: codigoController,
                  decoration: const InputDecoration(labelText: 'Codigo'),
                ),
                TextField(
                  controller: escuelaController,
                  decoration: const InputDecoration(labelText: 'Escuela'),
                ),
                TextField(
                  controller: modalidadController,
                  decoration: const InputDecoration(labelText: 'Modalidad'),
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  controller: creditosController,
                  decoration: const InputDecoration(labelText: 'Creditos'),
                ),

              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _guardarNuevoCurso(
                  nombreController.text,
                  codigoController.text,
                  int.parse(creditosController.text),
                  modalidadController.text,
                  escuelaController.text,
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
  void _guardarNuevoCurso(
      String nombre,
      String codigo,
      int creditos,
      String modalidad,
      String escuela,

      ) async {
    try {
      final url = Uri.parse('http://localhost:8000/ingresar-curso');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'codigo': codigo,
          'nombreCompleto': nombre,
          'escuela': escuela,
          'modalidad': modalidad,
          'creditos': creditos,

        }),
      );

      if (response.statusCode == 201) {
        print('curso guardado correctamente en la base de datos.');
        setState(() {
          cargarCursos();
        });
      } else {
        print('Error al guardar el curso en la base de datos: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al guardar el curso en la base de datos: $e');
    }
  }
}

