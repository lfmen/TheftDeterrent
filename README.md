# Theft Deterrent – Paquetes corregidos e instalador

> **Fork de [Jotalea/TheftDeterrent](https://github.com/Jotalea/TheftDeterrent).**  
> Todo el crédito por el repositorio original, los paquetes y la documentación es de **[Jotalea](https://github.com/Jotalea)**.  
> Este fork aporta una corrección de compatibilidad para distribuciones Debian modernas.

---

## ¿Qué es Theft Deterrent?

Theft Deterrent es un programa de rastreo y antirrobo para netbooks utilizado en las escuelas públicas argentinas (Plan Juana Manso / Conectar Igualdad). Reporta la ubicación del dispositivo a un servidor del gobierno para que las computadoras robadas o perdidas puedan ser recuperadas.

---

## El problema

En distribuciones Debian modernas (Linux Mint 21+, Ubuntu 22.04+, Huayra 6.5+), instalar Theft Deterrent desde los paquetes originales falla de dos maneras:

1. **`apt` roto / bucle de dependencias** – El paquete `theftdeterrentclient` original declara dependencias que no están disponibles en los repositorios actuales, haciendo que `dpkg`/`apt` entre en un estado irresoluble y dejando el gestor de paquetes roto.

2. **Crash silencioso del cliente gráfico** – Incluso resolviendo el problema de dependencias, el cliente gráfico (`theftdeterrentclient`) se cierra instantáneamente al abrirlo sin dar ningún error visible. El motivo es que los binarios del programa enlazan contra `libpython2.7`, una librería que fue eliminada de los repositorios oficiales de Ubuntu 22.04+ y Linux Mint 21+.

   > Un parche comunitario de [Maxelslasarte](https://huayra.educar.gob.ar/ayuda/?qa=user/Maxelslasarte) cambia la dependencia de Python 2 a Python 3 en los **metadatos** del paquete Guardian, pero los **binarios compilados** adentro del paquete siguen necesitando `libpython2.7` en tiempo de ejecución. Cambiar solo los metadatos no alcanza.

---

## La solución

Este repositorio incluye:

- **Paquetes `.deb` con el parche aplicado** — los cuatro paquetes necesarios para una instalación completa, con los metadatos de dependencias corregidos.
- **`install.sh`** — un script instalador inteligente que:
  1. Detecta la distribución automáticamente.
  2. Instala `libpython2.7` desde el repositorio oficial `universe`, o usa como fallback el archivo de Ubuntu Jammy (22.04) si la librería no está disponible en los repos de la distro actual (ej: Linux Mint 22 / Ubuntu 24.04). El repositorio temporal se elimina inmediatamente después de la instalación.
  3. Aplica el parche de Guardian si Python 2 no está presente en el sistema.
  4. Instala los cuatro paquetes en el orden correcto.
  5. Crea un enlace simbólico para que `theftdeterrentclient` esté disponible en todo el sistema.

---

## Instalación

### Windows 10 / 11

1. Descargá **`Theft Deterrent Guardian.exe`** e instalalo.
   Durante la instalación, marcá la casilla que aparece (permite desinstalar sin contraseña) y hacé clic en **Siguiente**.
2. Descargá **`Theft Deterrent Agent.exe`** e instalalo. Repetí el paso anterior.
3. Reiniciá la computadora.
4. Una vez que inicia, el programa debería abrirse automáticamente.
5. Andá a **Configuración** y poné el servidor en `citd.dgp.educ.ar`.
   Si no funciona (la computadora no es una Juana Manso), probá con `tds.educacion.gob.ar`.

---

### Huayra Linux

Funciona en **Huayra 5** y **Huayra 6**. Para **Huayra 6.5**, seguí las instrucciones de Debian que están abajo.

1. Abrí **Configuración → Gestor de paquetes Synaptic** (o algo similar).
2. Buscá `theft`.
3. Seleccioná los cuatro paquetes y marcalos para instalar (doble clic en la casilla).
4. Hacé clic en **Aplicar**.
5. Continuá con [Post-instalación](#post-instalación).

Si no te funciona, podés seguir los pasos de Debian o ver [este repositorio oficial de Huayra](https://github.com/HuayraLinux/theftdeterrent6).

---

### Linux basado en Debian (Linux Mint, Ubuntu, Kali, Huayra 6.5, etc.)

> ⚠️ **No uses el comando `curl` original del repositorio upstream** — va a descargar los paquetes sin corregir.
> Usá los paquetes y el script de **este repositorio**.

#### Opción A – Instalador automático (recomendado)

**Paso 1 – Copiá la carpeta a la máquina Linux**

Si estás en Windows, copiá la carpeta `TheftDeterrent` completa a un pendrive, conectalo en la computadora con Linux y pegala en tu carpeta personal (o en `Documentos`).

**Paso 2 – Abrí una terminal dentro de la carpeta**

Hacé clic derecho en un espacio vacío dentro de la carpeta `TheftDeterrent` y seleccioná **"Abrir en un terminal"** (o "Open in Terminal").

**Paso 3 – Ejecutá el instalador**

```bash
sudo bash install.sh
```

Cuando te pida la contraseña, escribila normalmente. **No se van a ver asteriscos ni puntitos en la pantalla** mientras escribís — es una medida de seguridad de Linux. Presioná **Enter** al terminar.

El script va a:
- Instalar `libpython2.7` (necesaria para el cliente gráfico, incluso en sistemas solo con Python 3).
- Aplicar el parche de Guardian si Python 2 no está presente.
- Instalar los cuatro paquetes en el orden correcto.
- Crear el comando `theftdeterrentclient` disponible en todo el sistema.

Continuá con [Post-instalación](#post-instalación).

#### Opción B – Instalación manual

```bash
sudo dpkg -i theftdeterrentclient-lib_6.0.0.11.huayra10_amd64.deb
sudo dpkg -i theftdeterrentdaemon_6.0.0.11.huayra10_amd64.deb
sudo dpkg -i theftdeterrentguardian_6.0.0.11.huayra10_amd64.deb
sudo dpkg -i theftdeterrentclient_6.0.0.11.huayra10_amd64.deb
```

> Si `dpkg` se queja por dependencias no satisfechas, ejecutá `sudo apt-get install -f` después.

---

### Opciones del instalador (`install.sh`)

| Opción | Abreviación | Descripción |
|--------|-------------|-------------|
| `--solo-descarga` / `--download-only` | `-D` | Solo descarga los paquetes, no los instala |
| `--no-limpiar` / `--no-cleanup` | | Conserva los archivos `.deb` después de instalar |
| `--no-log` | | Deshabilita la creación del archivo de log |
| `--log <archivo>` | `-L` | Escribe el log en un archivo personalizado |
| `--dir <ruta>` | | Usa un directorio de trabajo distinto |
| `--mirror <URL>` | `-M` | Descarga desde un mirror alternativo |
| `--ejecutar` | `-E` | Ejecuta el programa al terminar la instalación |
| `--help` | `-H` | Muestra la ayuda y sale |

---

## Post-instalación

1. **Reiniciá la computadora** (recomendado).
2. Abrí **Theft Deterrent** desde el menú de aplicaciones, o ejecutalo desde la terminal:
   ```bash
   theftdeterrentclient
   ```
3. Dentro del programa, andá a **Configuración** y poné el servidor en `citd.dgp.educ.ar`.
   Si ese servidor no funciona (computadora que no es Juana Manso), probá con `tds.educacion.gob.ar`.

Así se ve la pantalla de configuración:

![Pestaña de configuración de TDA](https://github.com/Jotalea/TheftDeterrent/assets/67925603/d91dac51-2cc4-4ff1-a9b3-2714ee34069d)

Y así se ve la pantalla principal (mostrando el Hardware ID y el Nombre de Grupo):

![Pestaña principal de TDA](https://github.com/Jotalea/TheftDeterrent/assets/67925603/a22b1b2b-b3fc-4f65-8ba1-6793631d00e6)

---

## Créditos

| Quién | Aporte |
|-------|--------|
| [Jotalea](https://github.com/Jotalea) | Repositorio original, paquetes y documentación |
| [Maxelslasarte](https://huayra.educar.gob.ar/ayuda/?qa=user/Maxelslasarte) | Parche de Guardian (cambio de dependencia Python 2 → Python 3 en los metadatos del paquete) |
| [HuayraLinux](https://github.com/HuayraLinux/theftdeterrent6) | Paquetes oficiales de Huayra |

---

## Repositorios relacionados

- [Jotalea/TheftDeterrent](https://github.com/Jotalea/TheftDeterrent) — repositorio original (upstream)
- [HuayraLinux/theftdeterrent6](https://github.com/HuayraLinux/theftdeterrent6) — paquetes oficiales de Huayra 6
- [HuayraLinux/theftdeterrent4](https://github.com/HuayraLinux/theftdeterrent4) — paquetes de Huayra 4

---

## Licencia

El software Theft Deterrent es propiedad del Ministerio de Educación de la República Argentina. Este repositorio solo redistribuye los paquetes existentes con correcciones de compatibilidad aplicadas. El script instalador (`install.sh`) se publica bajo la [Licencia MIT](LICENSE).
