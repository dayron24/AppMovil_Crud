package cursoModel

//NOTA IMPORTANTE****************
//las funciones con la primera letra minuscula son privadas e inaccesibles desde main
//Se debe usar nombres con la primera letra mayuscula para que sea publicos

import (
	"database/sql"
	"net/http"

	"github.com/gin-gonic/gin"
	_ "github.com/go-sql-driver/mysql"
)

type curso struct {
	Codigo         string `json:"codigo"`
	NombreCompleto string `json:"nombreCompleto"`
	Escuela        string `json:"escuela"`
	Modalidad      string `json:"modalidad"`
	Creditos       int    `json:"creditos"`
}

const dbURI = "root:vLHKjdfQNSpvEpiDNYUrqjcAaGTOkspb@tcp(monorail.proxy.rlwy.net:23285)/railway"

var db *sql.DB

func GetCursos(c *gin.Context) {
	db, err := sql.Open("mysql", dbURI)
	if err != nil {
		panic(err.Error())
	}
	defer db.Close()

	rows, err := db.Query("SELECT codigo, nombre, escuela, modalidad, creditos FROM Cursos")
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	defer rows.Close()

	var cursos []curso
	for rows.Next() {
		var curso curso
		err := rows.Scan(&curso.Codigo, &curso.NombreCompleto, &curso.Escuela, &curso.Modalidad, &curso.Creditos)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		cursos = append(cursos, curso)
	}

	c.JSON(http.StatusOK, cursos)
}

func PostCursos(c *gin.Context) {
	// Configurar la conexión a la base de datos MySQL

	db, err := sql.Open("mysql", dbURI)
	if err != nil {
		panic(err.Error())
	}
	defer db.Close()

	var newCurso curso
	if err := c.BindJSON(&newCurso); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	_, error := db.Exec("INSERT INTO Cursos (codigo,nombre, escuela, modalidad, creditos) VALUES (?, ?, ?, ?, ?)",
		newCurso.Codigo, newCurso.NombreCompleto, newCurso.Escuela, newCurso.Modalidad, newCurso.Creditos)
	if error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": error.Error()})
		return
	}

	c.JSON(http.StatusCreated, "Curso ingresado")
}
func DeleteCurso(c *gin.Context) {
	// Configurar la conexión a la base de datos MySQL
	db, err := sql.Open("mysql", dbURI)
	if err != nil {
		panic(err.Error())
	}
	defer db.Close()

	// Obtener el carnet del curso a eliminar del parámetro de la URL
	codigo := c.Param("codigo")

	// Ejecutar la consulta DELETE
	_, err = db.Exec("DELETE FROM Cursos WHERE codigo = ?", codigo)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, "Curso eliminado")
}

func UpdateCurso(c *gin.Context) {
	// Configurar la conexión a la base de datos MySQL
	db, err := sql.Open("mysql", dbURI)
	if err != nil {
		panic(err.Error())
	}
	defer db.Close()

	// Obtener el carnet del curso a actualizar del parámetro de la URL
	codigo := c.Param("codigo")

	// Obtener los nuevos datos del curso del cuerpo de la solicitud
	var updatedCurso curso
	if err := c.BindJSON(&updatedCurso); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Ejecutar la consulta UPDATE
	_, err = db.Exec("UPDATE Cursos SET nombre = ?, escuela = ?, modalidad = ?, creditos = ? WHERE codigo = ?",
		updatedCurso.NombreCompleto, updatedCurso.Escuela, updatedCurso.Modalidad, updatedCurso.Creditos, codigo)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, "Curso actualizado")
}

func DropTableCursos(c *gin.Context) {
	// Abrir la conexión a la base de datos MySQL
	db, err := sql.Open("mysql", dbURI)
	if err != nil {
		panic(err.Error())
	}
	defer db.Close()

	// Ejecutar la consulta para borrar la tabla
	_, err = db.Exec("DROP TABLE IF EXISTS Cursos")
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, "Tabla borrada")
}
func CreateTable(c *gin.Context) {
	// Abrir la conexión a la base de datos MySQL
	db, err := sql.Open("mysql", dbURI)
	if err != nil {
		panic(err.Error())
	}
	defer db.Close()

	// Ejecutar la consulta para borrar la tabla
	_, err = db.Exec(`CREATE TABLE Cursos (
        codigo VARCHAR(25),
        nombre VARCHAR(30),
        escuela VARCHAR(30),
        modalidad VARCHAR(30),
        creditos INT
    );`)
	if err != nil {
		// Manejar el error

		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, "Tabla creada")
}
