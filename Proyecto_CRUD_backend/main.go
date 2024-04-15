package main

import (
	"fmt"

	cursoModel "github.com/ApiRest_Golang/models/cursoModel"
	estudianteModel "github.com/ApiRest_Golang/models/estudianteModel"
	estudiantexcursoModel "github.com/ApiRest_Golang/models/estudianteXCursoModel"
	"github.com/gin-gonic/gin"
)

func main() {
	fmt.Println("Iniciando GO Api")

	// Iniciar el enrutador Gin
	router := gin.Default()

	// ENDPOINT DE ESTUDIANTE
	router.GET("/get-estudiantes", estudianteModel.GetEstudiantes)
	router.POST("/ingresar-estudiante", estudianteModel.PostEstudiantes)
	router.DELETE("/eliminar-estudiante/:carnet", estudianteModel.DeleteEstudiante)
	router.PUT("/actualizar-estudiante/:carnet", estudianteModel.UpdateEstudiante)

	//ENDPOINTS DE CURSO
	router.GET("/get-cursos", cursoModel.GetCursos)
	router.POST("/ingresar-curso", cursoModel.PostCursos)
	router.DELETE("/eliminar-curso/:codigo", cursoModel.DeleteCurso)
	router.PUT("/actualizar-curso/:codigo", cursoModel.UpdateCurso)
	router.DELETE("/borrar-tabla-curso", cursoModel.DropTableCursos)
	router.POST("/crear-tabla-curso", cursoModel.CreateTable)

	//ENDPOINTS DE Estudiante X Curso
	router.GET("/get-estudiantesXCursos/:codigoCurso", estudiantexcursoModel.GetEstudiantesPorCurso)
	router.GET("/get-estudiantes-NO-en-curso/:codigoCurso", estudiantexcursoModel.GetEstudiantesNoEnCurso)
	router.POST("/ingresar-estudianteXCurso", estudiantexcursoModel.PostEstudianteXCurso)
	router.DELETE("/borrar-estudianteXCurso:codigoCurso/:codigo/:carnet", estudiantexcursoModel.DeleteEstudianteXCurso)

	//Abre el servidor
	router.Run("localhost:8000")
}
