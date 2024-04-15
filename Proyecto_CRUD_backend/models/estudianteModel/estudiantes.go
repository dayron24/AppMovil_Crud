package estudianteModel

//NOTA IMPORTANTE****************
//las funciones con la primera letra minuscula son privadas e inaccesibles desde main
//Se debe usar nombres con la primera letra mayuscula para que sea publicos

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

const dbURI = "root:vLHKjdfQNSpvEpiDNYUrqjcAaGTOkspb@tcp(monorail.proxy.rlwy.net:23285)/railway"

var db *sql.DB

func GetEstudiantes(c *gin.Context) {
	db, err := sql.Open("mysql", dbURI)
	if err != nil {
		panic(err.Error())
	}
	defer db.Close()

	rows, err := db.Query("SELECT * FROM Estudiantes")
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

func PostEstudiantes(c *gin.Context) {
	// Configurar la conexión a la base de datos MySQL

	db, err := sql.Open("mysql", dbURI)
	if err != nil {
		panic(err.Error())
	}
	defer db.Close()

	var newEstudiante estudiante
	if err := c.BindJSON(&newEstudiante); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	_, error := db.Exec("INSERT INTO Estudiantes (carnet,nombre, celular, correo, carrera, fechaNacimiento) VALUES (?, ?, ?, ?, ?, ?)",
		newEstudiante.Carnet, newEstudiante.NombreCompleto, newEstudiante.NumeroCelular, newEstudiante.Correo, newEstudiante.Carrera, newEstudiante.FechaNacimiento)
	if error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": error.Error()})
		return
	}

	c.JSON(http.StatusCreated, "Estudiante ingresado")
}
func DeleteEstudiante(c *gin.Context) {
	// Configurar la conexión a la base de datos MySQL
	db, err := sql.Open("mysql", dbURI)
	if err != nil {
		panic(err.Error())
	}
	defer db.Close()

	// Obtener el carnet del estudiante a eliminar del parámetro de la URL
	carnet := c.Param("carnet")

	// Ejecutar la consulta DELETE
	_, err = db.Exec("DELETE FROM Estudiantes WHERE carnet = ?", carnet)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, "Estudiante eliminado")
}

func UpdateEstudiante(c *gin.Context) {
	// Configurar la conexión a la base de datos MySQL
	db, err := sql.Open("mysql", dbURI)
	if err != nil {
		panic(err.Error())
	}
	defer db.Close()

	// Obtener el carnet del estudiante a actualizar del parámetro de la URL
	carnet := c.Param("carnet")

	// Obtener los nuevos datos del estudiante del cuerpo de la solicitud
	var updatedEstudiante estudiante
	if err := c.BindJSON(&updatedEstudiante); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Ejecutar la consulta UPDATE
	_, err = db.Exec("UPDATE Estudiantes SET nombre = ?, celular = ?, correo = ?, carrera = ?, fechaNacimiento = ? WHERE carnet = ?",
		updatedEstudiante.NombreCompleto, updatedEstudiante.NumeroCelular, updatedEstudiante.Correo, updatedEstudiante.Carrera, updatedEstudiante.FechaNacimiento, carnet)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, "Estudiante actualizado")
}
