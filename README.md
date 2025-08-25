# HuellaCarbono

HuellaCarbono es una aplicación multiplataforma que permite a estudiantes universitarios calcular su huella de carbono personal a partir de sus hábitos diarios, consumo energético, desplazamientos y actividades académicas.

## Características principales

- **Formulario interactivo:** Los estudiantes completan un formulario con datos sobre transporte, energía, proyectos universitarios, gestión de residuos y hábitos personales.
- **Cálculo de huella de carbono:** La app envía los datos al backend, que estima las emisiones de CO₂ (kg) y devuelve recomendaciones personalizadas para reducir el impacto ambiental.
- **Visualización de resultados:** Los usuarios pueden ver su huella estimada y recibir consejos para mejorar sus hábitos.
- **Donaciones ambientales:** Se ofrece la opción de donar a fundaciones que trabajan en la protección del medio ambiente, reforestación, energías renovables y compensación de emisiones.

## Tecnologías utilizadas

- **Frontend:** Flutter (Dart)
- **Backend:** Python (FastAPI)
- **Plataformas:** Android, iOS, Web, Windows, Linux, macOS

## Estructura del proyecto

- `frontend/`: Aplicación Flutter con pantallas para el formulario, resultados y donaciones.
- `backend/`: API en Python para procesar los datos y calcular la huella de carbono.

## Instalación y ejecución

### Requisitos previos

- Tener instalado [Flutter SDK](https://docs.flutter.dev/get-started/install) y Dart (incluido en Flutter).
- Python 3.10 o superior.

### Instalación de dependencias

#### Backend

```bash
cd backend
pip install -r requirements.txt
```

#### Frontend

```bash
cd frontend
flutter pub get
```

### Ejecución

#### Backend (API)

```bash
uvicorn main:app --reload
```

#### Frontend (App Flutter)

```bash
flutter run
```

## Requerimientos

### backend/requirements.txt

```
fastapi
uvicorn
```

### frontend/pubspec.yaml (fragmento relevante)

```yaml
dependencies:
	flutter:
		sdk: flutter
	http: ^1.2.0
	cupertino_icons: ^1.0.6
```

## Cómo usar

1. Completa el formulario con tus datos y hábitos.
2. Recibe tu huella de carbono estimada y recomendaciones.
3. Si lo deseas, realiza una donación a una fundación ambiental.