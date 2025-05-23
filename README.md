# Frontend Móvil - Sota, Caballo y Rey
 

## Descripción
Este repositorio continene el código fuente del frontend para la aplicación de móvil Sota, Caballo y Rey.


## Tecnologías
* Framework: Flutter.

* Lenguaje: Dart.

* Entorno de simulación: Android Studio.

## Clonación del Repositorio

Para clonar el repositorio en tu máquina local, asegúrate de seguir los siguientes pasos en el orden indicado:

1. Confirma que tu máquina tiene instalado Git en su versión 2.47.1 en adelante:
```bash
git --version
```

2. Clona el repositorio en tu directorio de trabajo actual:
```bash
git clone https://github.com/UNIZAR-30226-2025-01/guignote-frontend-smartphone
```

3. Cambia tu directorio de trabajo actual a la carpeta del proyecto:
```bash
cd guignote-frontend-smartphone
```

## Instalación de Dependencias

1. Asegúrate de tener instalado Flutter. Si no lo tienes, puedes instalarlo siguiendo las instrucciones de la [documentación oficial de Flutter](https://docs.flutter.dev/get-started/install?_gl=1*qgu9hf*_ga*MTEzNTAzMjY5My4xNzM5MDA5ODkz*_ga_04YGWK0175*MTczOTAwOTg5NC4xLjAuMTczOTAwOTg5NC4wLjAuMA..).

2. Instala las dependencias del proyecto:
```bash
flutter pub get
```

## Ejecución de la aplicación en dispositivos android

Descarga e instala el archivo app-release.apk disponible en la parte de releases.

## Flujo de trabajo

Este proyecto sigue un flujo de trabajo simplificado basado en la estrategia de ramas GitFlow para mantener un desarrollo ordenado.

### Ramas principales
   * `main`: Contiene la versión estable y lista para producción. Solo se actualiza este código cuando está probado y completamente funcional.
   
   * `develop`: Rama de desarrollo donde se integran nuevas funcionalidades antes de pasar a main. Todas las funcionalidades en desarrollo se deben realizar en ramas separadas que se fusionaran en develop 
  
### Ramas auxiliares
* `feature/nombre-de-la-feature`: Para nuevas funcionalidades.
  
* `hotfix/nombre-de-la-hotfix`: Para correcciones urgentes.
  
* `release/nombre-de-la-release`: Para preparar nuevas versiones antes de pasarlas a `main`.


### Uso del flujo propuesto

Se explica con funcionalidades, pero para bugs o versiones el proceso seria idéntico.

 **1. **Crear una nueva funcionalidad****

 Cada desarrollador crea una rama desde develop para trabajar en nuevas funcionalidades. La convención de nombres es `features/nombre-de-la-funcionalidad`.
```bash
git checkout develop
git checkout -b feature/nueva-funcionalidad
```

 **2. **Desarrollo y pruebas****
* Una vez que se ha desarrollado la funcionalidad, se deben realizar pruebas locales.

**3. **Hacer merge a `develop`****

* Una vez que la funcionalidad esté probada, se hace merge de la funcionalidad a la rama `develop`.

* **Importante**: Antes de fusionar, asegúrate que tu código está limpio y que pasa las pruebas correctamente.

```bash
git checkout develop
git merge feature/nueva-funcionalidad develop
```
**4. **Eliminar ramas de funcionalidad****

Una vez hecho el merge, puedes eliminar la rama de funcionalidad tanto en local como en remoto.
```bash
git branch -d feature/nueva-funcionalidad
git push origin --delete feature/nueva-funcionalidad
```

## Política de Contribución

Este es un repositorio público, pero no se aceptan contribuciones externas. El desarrollo del proyecto está restringido única y exclusivamente a los integrantes de la organización.

## Licencia

Este proyecto está licenciado bajo la [Licencia MIT](LICENSE). 
