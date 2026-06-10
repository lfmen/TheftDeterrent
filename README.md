<div align="center">

# Theft Deterrent Fix & Installer

[![Basado en](https://img.shields.io/badge/Basado_en-Jotalea%2FTheftDeterrent-lightgray)](https://github.com/Jotalea/TheftDeterrent)
[![License: MIT](https://img.shields.io/badge/License-MIT-0071C5)](https://opensource.org/licenses/MIT)
[![OS Support](https://img.shields.io/badge/OS-Linux%20%7C%20Windows-0071C5)](#instalación)

> **Solución definitiva y script de autoconfiguración para Theft Deterrent en distribuciones Linux modernas y Windows.**

</div>

> [!NOTE]
> **Basado en el trabajo de [Jotalea/TheftDeterrent](https://github.com/Jotalea/TheftDeterrent)**.  
> Todos los créditos del repositorio original, la paquetización base y la documentación primaria corresponden a **[Jotalea](https://github.com/Jotalea)**.

## Tabla de Contenidos

- [Compatibilidad](#compatibilidad)
- [El Problema](#el-problema)
- [La Solución](#la-solución)
- [Instalación rápida](#instalación-rápida)
- [Instalación detallada](#instalación-detallada)
  - [Linux (Debian / Ubuntu / derivadas)](#linux-debian-ubuntu-linux-mint-kali-huayra-65)
  - [Huayra 5 / 6](#huayra-5--6)
  - [Windows 10 / 11](#windows-10--11)
- [Post-Instalación](#post-instalación)
- [Referencias](#referencias-y-repositorios)
- [Licencia](#licencia)

## Compatibilidad

| Sistema operativo | Versión | Estado | Notas |
|:---|:---|:---:|:---|
| Linux Mint | 22.3 | ✓ | Probado. Requiere `install.sh` |
| Linux Mint | 21+ | ? | No probado |
| Linux Mint | 20 | ? | No probado |
| Ubuntu | 22.04 LTS (Jammy) | ? | No probado |
| Ubuntu | 20.04 LTS (Focal) | ? | No probado |
| Huayra | 6.5+ | ? | No probado |
| Huayra | 5 / 6 | ? | No probado. Instalación nativa via `apt` según documentación original |
| Kali Linux | Rolling | ? | No probado |
| Debian | 12 (Bookworm) | ? | No probado |
| Windows | 10 / 11 | ✓ | Instaladores en `windows/` |

## El Problema

En distribuciones modernas (como **Linux Mint 21+, Ubuntu 22.04+ o Huayra 6.5+**), la instalación de los paquetes `.deb` originales presenta fallos críticos que impiden su funcionamiento:

1. **Dependencias irresolubles:** El paquete `theftdeterrentclient` exige dependencias *deprecadas*, lo cual rompe la base de datos de `apt`.
2. **Crash silencioso del cliente:** Los binarios están enlazados estáticamente contra `libpython2.7`, una librería que ya ha sido eliminada de los repositorios actuales.

> [!WARNING]
> **Nota sobre parches previos:**  
> El parche comunitario provisto por [Maxelslasarte](https://huayra.educar.gob.ar/ayuda/?qa=user/Maxelslasarte) corrige los *metadatos* (cambiando la dependencia a Python 3), pero **no soluciona** el crash de los *binarios*, ya que estos siguen requiriendo la librería original (`libpython2.7`) en tiempo de ejecución.

## La Solución

Esta solución consta de un **instalador automatizado (`install.sh`)** diseñado para resolver todos los conflictos de dependencias de forma dinámica y transparente para el usuario:

- **Instalación de dependencias legacy:** Obtiene `libpython2.7` directamente del repositorio `universe` o mediante un *fallback* temporal al archivo de Ubuntu Jammy.
- **Aplicación inteligente de parches:** Despliega los metadatos parcheados de *Guardian* únicamente si el sistema carece de un entorno Python 2 nativo.
- **Integración del sistema:** Crea los enlaces simbólicos necesarios para disponer del comando `theftdeterrentclient` de forma global.

## Instalación rápida

```bash
git clone https://github.com/lfmen/TheftDeterrent.git && cd TheftDeterrent && sudo bash install.sh
```

## Instalación detallada

### Linux (Debian, Ubuntu, Linux Mint, Kali, Huayra 6.5+)

Para instalar, clona este repositorio y ejecuta el script automatizado con privilegios de administrador:

```bash
# 1. Clonar el repositorio
git clone https://github.com/lfmen/TheftDeterrent.git

# 2. Ingresar al directorio
cd TheftDeterrent

# 3. Ejecutar el instalador
sudo bash install.sh
```

> [!TIP]
> Para instalaciones manuales o auditorías de seguridad, los paquetes `.deb` originales se encuentran aislados en el directorio `deb/`.

### Huayra 5 / 6

Procede con la instalación convencional a través del gestor de paquetes (Synaptic o `apt` instalando el meta-paquete `theft`). 
*Si ocurren conflictos de dependencias, recurre al método de instalación de Debian descrito en la sección anterior.*

### Windows 10 / 11

1. Ejecuta el instalador ubicado en `windows/Theft Derrent Guardian.exe` *(asegúrate de habilitar la opción de desinstalación sin contraseña)*.
2. Ejecuta el instalador `windows/Theft Derrent Agent.exe`.
3. **Reinicia** el sistema operativo.

## Post-Instalación

Una vez instalado, sigue estos pasos para vincular tu equipo:

1. Inicia el demonio o cliente ejecutando el comando `theftdeterrentclient` en la terminal, o búscalo en tu menú de aplicaciones.
2. Navega al panel de **Configuración**.
3. Configura el servidor correspondiente a tu red:
   - **Red Juana Manso:** `citd.dgp.educ.ar`
   - **Otros equipos:** `tds.educacion.gob.ar`

<details>
<summary>Referencias y repositorios</summary>

- [Jotalea/TheftDeterrent](https://github.com/Jotalea/TheftDeterrent) - Repositorio y documentación original.
- [Parche de Maxelslasarte](https://huayra.educar.gob.ar/ayuda/?qa=user/Maxelslasarte) - Adaptación de metadatos de Guardian.
- [HuayraLinux/theftdeterrent6](https://github.com/HuayraLinux/theftdeterrent6) - Paquetización oficial para entornos Huayra 6.

</details>

## Licencia

El cliente de Theft Deterrent es propiedad del **Ministerio de Educación de la República Argentina**. 

El instalador, scripts y herramientas de despliegue de este repositorio se distribuyen bajo la [Licencia MIT](LICENSE).

<div align="center">
  <i>Desarrollado para mantener la compatibilidad en entornos educativos</i>
</div>
