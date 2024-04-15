package estudiantexcursoModel

import (
	"database/sql"
	"net/http"

	"github.com/gin-gonic/gin"
	_ "github.com/go-sql-driver/mysql"
)

type estudiante struct {
	ID              int    `json:"id"`
	NombreCompleto  string `json:"nombreCompleto"`
	Carnet          int    `json:"carnet"`
	NumeroCelular   string `json:"numeroCelular"`
	Correo          string `json:"correo"`
	Carrera         string `json:"carrera"`
	FechaNacimiento string `json:"fechaNacimiento"`
}

// BindJSON para obtener los datos del cuerpo de la solicitud
var Registro struct {
	CarnetEstudiante int    `json:"carnetEstudiante"`
	CodigoCurso      string `json:"codigoCurso"`
}

const dbURI = "root:vLHKjdfQNSpvEpiDNYUrqjcAaGTOkspb@tcp(monorail.proxy.rlwy.net:23285)/railway"

var db *sql.DB

func PostEstudianteXCurso(c *gin.Context) {
	// Configurar la conexión a la base de datos MySQL
	db, err := sql.Open("mysql", dbURI)
	if err != nil {
		panic(err.Error())
	}
	defer db.Close()

	if err := c.BindJSON(&Registro); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Ejecutar la consulta INSERT
	_, err = db.Exec("INSERT INTO EstudiantesXCurso (carnetEstudiante, codigoCurso) VALUES (?, ?)",
		Registro.CarnetEstudiante, Registro.CodigoCurso)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, "Registro ingresado en EstudiantesXCurso")
}

func GetEstudiantesPorCurso(c *gin.Context) {
	// Configurar la conexión a la base de datos MySQL
	db, err := sql.Open("mysql", dbURI)
	if err != nil {
		panic(err.Error())
	}
	defer db.Close()

	// Obtener el código del curso de los parámetros de la URL
	codigoCurso := c.Param("codigoCurso")

	// Ejecutar la consulta SELECT
	rows, err := db.Query("SELECT carnet, nombre, celular, correo, carrera, fechaNacimiento FROM Estudiantes JOIN EstudiantesXCurso ON Estudiantes.carnet = EstudiantesXCurso.carnetEstudiante WHERE EstudiantesXCurso.codigoCurso = ?", codigoCurso)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	defer rows.Close()

	var estudiantes []estudiante
	for rows.Next() {
		var est estudiante
		err := rows.Scan(&est.Carnet, &est.NombreCompleto, &est.NumeroCelular, &est.Correo, &est.Carrera, &est.FechaNacimiento)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		estudiantes = append(estudiantes, est)
	}

	c.JSON(http.StatusOK, estudiantes)
}

func GetEstudiantesNoEnCurso(c *gin.Context) {
	// Configurar la conexión a la base de datos MySQL
	db, err := sql.Open("mysql", dbURI)
	if err != nil {
		panic(err.Error())
	}
	defer db.Close()

	// Obtener el código del curso de los parámetros de la URL
	codigoCurso := c.Param("codigoCurso")

	// Ejecutar la consulta SELECT
	rows, err := db.Query(`
    SELECT e.carnet, e.nombre, e.celular, e.correo, e.carrera, e.fechaNacimiento
    FROM Estudiantes e
    LEFT JOIN EstudiantesXCurso ec ON e.carnet = ec.carnetEstudiante AND ec.codigoCurso = ?
    WHERE ec.carnetEstudiante IS NULL
`, codigoCurso)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	defer rows.Close()

	var estudiantes []estudiante
	for rows.Next() {
		var est estudiante
		err := rows.Scan(&est.Carnet, &est.NombreCompleto, &est.NumeroCelular, &est.Correo, &est.Carrera, &est.FechaNacimiento)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		estudiantes = append(estudiantes, est)
	}

	c.JSON(http.StatusOK, estudiantes)
}

func DeleteEstudianteXCurso(c *gin.Context) {
	// Configurar la conexión a la base de datos MySQL
	db, err := sql.Open("mysql", dbURI)
	if err != nil {
		panic(err.Error())
	}
	defer db.Close()

	// Obtener el ID del registro a eliminar del parámetro de la URL
	codigo := c.Param("codigo")
	carnet := c.Param("carnet")
	// Ejecutar la consulta DELETE
	_, err = db.Exec("DELETE FROM EstudiantesXCurso WHERE codigoCurso = ? AND carnetEstudiante = ?", codigo, carnet)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, "Registro eliminado de EstudiantesXCurso")
}
