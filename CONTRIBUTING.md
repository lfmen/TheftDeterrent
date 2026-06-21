# Guía de Contribución

Gracias por tu interés en contribuir a este proyecto. Cualquier mejora es bienvenida, ya sea un reporte de bug, una corrección o una nueva funcionalidad.

## Antes de empezar

- Revisá los [issues abiertos](https://github.com/lfmen/TheftDeterrent/issues) para ver si alguien ya reportó o está trabajando en lo mismo.
- Si tu cambio es significativo (nueva funcionalidad, refactor grande), abrí un issue primero para discutirlo antes de ponerte a codear.

## Cómo reportar un bug

Usá la plantilla de **Bug Report** al abrir un nuevo issue. Incluí siempre:

- Distribución Linux o versión de Windows que usás.
- Salida completa del comando que falló (copiá el texto de la terminal).
- Pasos exactos para reproducir el problema.

## Cómo proponer una mejora

Usá la plantilla de **Feature Request** al abrir un nuevo issue. Describí:

- Qué problema resolvería la mejora.
- Cómo imaginás que debería funcionar.

## Cómo enviar cambios (Pull Request)

1. Hacé un fork del repositorio.
2. Creá una rama con un nombre descriptivo:
   ```bash
   git checkout -b fix/nombre-del-bug
   # o
   git checkout -b feat/nombre-de-la-feature
   ```
3. Hacé tus cambios. Si modificás `install.sh`, probalo en al menos una distribución compatible antes de enviar.
4. Hacé commit con mensajes claros y en español:
   ```bash
   git commit -m "fix: corrección del fallback de libpython2.7 en ubuntu jammy"
   ```
5. Abrí el Pull Request hacia la rama `main` y describí qué cambiaste y por qué.

## Estilo de código

- El script `install.sh` está escrito en Bash. Mantené el mismo estilo de indentación (2 espacios) y los comentarios en español.
- Probá tu script con `bash -n install.sh` antes de hacer commit para verificar que no haya errores de sintaxis.

## Distros de prueba recomendadas

Para validar cambios en el instalador, los entornos más relevantes son:

- Ubuntu 22.04 LTS (Jammy)
- Linux Mint 21+
- Huayra 6.5+
- Kali Linux (rolling)
