from fastapi import FastAPI
from pydantic import BaseModel, Field

app = FastAPI(title="Huella de Carbono Estudiantes API")

class SurveyResponse(BaseModel):
    nombre: str = Field(..., description="Nombre del estudiante")
    carrera: str
    semestre: int
    edad: int
    transporte: str
    distancia_diaria_km: float
    dias_asistencia: int
    comparte_transporte: bool

    horas_laboratorio: float
    tipo_laboratorio: str
    usa_equipos_alto_consumo: bool
    equipos_usados: str = None

    horas_pc_dia: float
    dispositivo_principal: str
    consumo_electricidad_extra: bool
    tipo_consumo: str = None

    tipo_proyectos: str
    materiales_usados: str
    residuos_por_proyecto_kg: float
    proyectos_por_semestre: int

    clasifica_residuos: bool
    porcentaje_reciclaje: str
    residuos_peligrosos: bool
    laboratorio_gestiona_seguro: bool = None

    usa_botella: bool
    evita_imprimir: bool
    comidas_fuera_semana: int
    voluntariado_ambiental: bool

@app.post("/encuesta")
def send_survey(respuesta: SurveyResponse):
    # Factores de emisión (ejemplo aproximado)
    FACTOR_BUS = 0.05  # kg CO2 por km
    FACTOR_AUTO = 0.21
    FACTOR_MOTO = 0.15
    FACTOR_AVION = 0.285
    FACTOR_PC_HORA = 0.06

    # Calculo estimado transporte
    if respuesta.transporte.lower() == "bus":
        emisiones_transporte = FACTOR_BUS * respuesta.distancia_diaria_km * respuesta.dias_asistencia * 4
    elif respuesta.transporte.lower() == "automóvil":
        emisiones_transporte = FACTOR_AUTO * respuesta.distancia_diaria_km * respuesta.dias_asistencia * 4
    elif respuesta.transporte.lower() == "moto":
        emisiones_transporte = FACTOR_MOTO * respuesta.distancia_diaria_km * respuesta.dias_asistencia * 4
    else:
        emisiones_transporte = 0

    # Consumo de pc
    emisiones_pc = respuesta.horas_pc_dia * 30 * FACTOR_PC_HORA

    # Emisiones por laboratorio
    FACTOR_LAB_HORA = 0.08
    emisiones_laboratorio = respuesta.horas_laboratorio * 4 * FACTOR_LAB_HORA

    # Emisiones por residuos de proyectos
    FACTOR_RESIDUOS = 1.2  # kg CO2 por kg
    emisiones_residuos = respuesta.residuos_por_proyecto_kg * respuesta.proyectos_por_semestre * FACTOR_RESIDUOS

    # Emisiones por comidas fuera
    FACTOR_COMIDA = 2.5  # kg CO2 por comida
    emisiones_comida = respuesta.comidas_fuera_semana * 4 * FACTOR_COMIDA

    total = emisiones_transporte + emisiones_pc + emisiones_laboratorio + emisiones_residuos + emisiones_comida

    return {"mensaje": "Respuesta recibida","emisiones_estimadas_kgCO2": total, "data": respuesta}
