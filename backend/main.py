from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field

app = FastAPI(title="Huella de Carbono Estudiantes API")

# Permitir CORS para cualquier origen (desarrollo)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

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

class DonationRequest(BaseModel):
    email: str = Field(..., description="Correo electrónico del donante")
    foundation_name: str = Field(..., description="Nombre de la fundación")

@app.get("/")
def read_root():
    return {"mensaje": "API de Huella de Carbono Estudiantes", "status": "activo", "endpoints": ["/encuesta", "/donacion", "/docs"]}

@app.post("/donacion")
def save_donation(donacion: DonationRequest):
    # Guardar la donación en donaciones.txt
    with open("donaciones.txt", "a", encoding="utf-8") as f:
        from datetime import datetime
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        f.write(f"{timestamp} - Correo: {donacion.email} - Fundación: {donacion.foundation_name}\n")
    
    return {
        "mensaje": "Donación registrada exitosamente",
        "correo": donacion.email,
        "fundacion": donacion.foundation_name
    }


@app.post("/encuesta")
def send_survey(respuesta: SurveyResponse):
    import sys
    print("Datos recibidos en /encuesta:", file=sys.stderr)
    print(respuesta, file=sys.stderr)
    # Guardar los datos recibidos en resultados.txt
    with open("resultados.txt", "a", encoding="utf-8") as f:
        f.write("\n--- Nueva respuesta ---\n")
        for k, v in respuesta.dict().items():
            f.write(f"{k}: {v}\n")
    # Factores de emisión (ejemplo aproximado)
    FACTOR_BUS = 0.05  # kg CO2 por km
    FACTOR_AUTO = 0.21
    FACTOR_MOTO = 0.15
    FACTOR_PC_HORA = 0.06
    FACTOR_LAB_HORA = 0.08
    FACTOR_RESIDUOS = 1.2  # kg CO2 por kg
    FACTOR_COMIDA = 2.5  # kg CO2 por comida
    FACTOR_IMPRESION = 0.5  # kg CO2 por impresión semanal
    FACTOR_BOTELLA = -1.0  # kg CO2 ahorrado por usar botella
    FACTOR_VOLUNTARIADO = -2.0  # kg CO2 ahorrado por voluntariado
    FACTOR_RECICLAJE = {
        "Nada": 0,
        "Menos del 25%": -1,
        "25 – 50%": -2,
        "50 – 75%": -3,
        "Más del 75%": -4
    }
    FACTOR_CONSUMO_EXTRA = 0.1  # kg CO2 por hora extra
    FACTOR_LAB_SEGURO = -1.0  # kg CO2 ahorrado si laboratorio gestiona seguro

    # Transporte
    if respuesta.transporte.lower() == "bus":
        emisiones_transporte = FACTOR_BUS * respuesta.distancia_diaria_km * respuesta.dias_asistencia * 4
    elif respuesta.transporte.lower() == "automóvil":
        emisiones_transporte = FACTOR_AUTO * respuesta.distancia_diaria_km * respuesta.dias_asistencia * 4
    elif respuesta.transporte.lower() == "moto":
        emisiones_transporte = FACTOR_MOTO * respuesta.distancia_diaria_km * respuesta.dias_asistencia * 4
    else:
        emisiones_transporte = 0
    # Compartir transporte reduce huella
    if respuesta.comparte_transporte:
        emisiones_transporte *= 0.7

    # Consumo de pc
    emisiones_pc = respuesta.horas_pc_dia * 30 * FACTOR_PC_HORA
    if respuesta.dispositivo_principal.lower() == "laptop":
        emisiones_pc *= 0.7  # Laptop consume menos

    # Consumo extra electricidad en casa
    emisiones_extra = 0
    if respuesta.consumo_electricidad_extra:
        emisiones_extra = 5 * FACTOR_CONSUMO_EXTRA

    # Emisiones por laboratorio
    emisiones_laboratorio = respuesta.horas_laboratorio * 4 * FACTOR_LAB_HORA
    if respuesta.usa_equipos_alto_consumo:
        emisiones_laboratorio *= 1.2

    # Laboratorio gestiona seguro residuos peligrosos
    if respuesta.residuos_peligrosos and respuesta.laboratorio_gestiona_seguro:
        emisiones_laboratorio += FACTOR_LAB_SEGURO

    # Emisiones por residuos de proyectos
    emisiones_residuos = respuesta.residuos_por_proyecto_kg * respuesta.proyectos_por_semestre * FACTOR_RESIDUOS

    # Emisiones por comidas fuera
    emisiones_comida = respuesta.comidas_fuera_semana * 4 * FACTOR_COMIDA

    # Impresión de trabajos
    emisiones_impresion = 0
    if not respuesta.evita_imprimir:
        emisiones_impresion = FACTOR_IMPRESION

    # Botella reutilizable
    ahorro_botella = FACTOR_BOTELLA if respuesta.usa_botella else 0

    # Voluntariado ambiental
    ahorro_voluntariado = FACTOR_VOLUNTARIADO if respuesta.voluntariado_ambiental else 0

    # Reciclaje
    ahorro_reciclaje = FACTOR_RECICLAJE.get(respuesta.porcentaje_reciclaje, 0)

    total = (
        emisiones_transporte
        + emisiones_pc
        + emisiones_extra
        + emisiones_laboratorio
        + emisiones_residuos
        + emisiones_comida
        + emisiones_impresion
        + ahorro_botella
        + ahorro_voluntariado
        + ahorro_reciclaje
    )

    # Mostrar resultado en consola para back end 
    print(f"\n=== RESULTADO DEL CÁLCULO ===")
    print(f"Estudiante: {respuesta.nombre}")
    print(f"Carrera: {respuesta.carrera}")
    print(f"Emisiones estimadas: {round(total, 2)} kg CO2")
    print(f"===============================")
    
    recomendaciones = []
    
    # Recomendaciones basadas en transporte
    if emisiones_transporte > 20 and not respuesta.comparte_transporte:
        recomendaciones.append("Considera compartir transporte o usar transporte público para reducir tu huella de carbono.")
    elif emisiones_transporte > 15 and respuesta.transporte.lower() == "automóvil":
        recomendaciones.append("Intenta usar bicicleta o caminar para distancias cortas, o considera el transporte público.")
    
    # Recomendaciones sobre consumo de energía
    if emisiones_pc > 5:
        recomendaciones.append("Reduce el tiempo frente al computador o activa el modo de ahorro de energía para disminuir tu consumo.")
    elif respuesta.consumo_electricidad_extra:
        recomendaciones.append("Desconecta dispositivos electrónicos cuando no los uses para reducir el consumo extra de electricidad.")
    
    # Recomendaciones sobre residuos y reciclaje
    if not respuesta.clasifica_residuos or respuesta.porcentaje_reciclaje == "Nada":
        recomendaciones.append("Implementa la separación de residuos y aumenta tu porcentaje de reciclaje para reducir tu impacto ambiental.")
    elif emisiones_residuos > 10:
        recomendaciones.append("Busca maneras de reutilizar materiales en tus proyectos universitarios para generar menos residuos.")
    
    # Recomendaciones sobre hábitos
    if not respuesta.usa_botella:
        recomendaciones.append("Usa una botella reutilizable en lugar de botellas desechables para reducir residuos plásticos.")
    elif not respuesta.evita_imprimir:
        recomendaciones.append("Intenta trabajar digitalmente y evita imprimir documentos innecesariamente.")
    elif emisiones_comida > 20:
        recomendaciones.append("Considera preparar más comidas en casa y reduce las comidas fuera para disminuir tu huella de carbono.")
    
    # Recomendaciones generales basadas en el total
    if total > 50:
        if "Considera compartir transporte" not in str(recomendaciones):
            recomendaciones.append("Tu huella de carbono es alta. Enfócate en reducir el transporte y el consumo energético.")
    elif total < 10:
        recomendaciones.append("¡Excelente! Tienes una huella de carbono baja. Considera hacer voluntariado ambiental para ayudar a otros.")
    
    # Limitar a 3 recomendaciones
    recomendaciones = recomendaciones[:3]
    
    # Mostrar recomendaciones en consola
    print(f"\n=== RECOMENDACIONES ===")
    for i, recomendacion in enumerate(recomendaciones, 1):
        print(f"{i}. {recomendacion}")
    print(f"=======================\n")
    
    return {
        "mensaje": "Respuesta recibida",
        "emisiones_estimadas_kgCO2": round(total, 2),
        "recomendaciones": recomendaciones,
        "data": respuesta
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)
