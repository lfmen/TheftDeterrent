# Theft Deterrent Fix & Installer

> **Fork de [Jotalea/TheftDeterrent](https://github.com/Jotalea/TheftDeterrent)**.  
> Créditos totales del repositorio original, la paquetización y la documentación primaria a **[Jotalea](https://github.com/Jotalea)**.

Este repositorio provee una solución de compatibilidad para ejecutar Theft Deterrent en distribuciones Linux modernas basadas en Debian.

---

## El Problema

En distribuciones modernas (como Linux Mint 21+, Ubuntu 22.04+ o Huayra 6.5+), la instalación de los paquetes `.deb` originales presenta fallos críticos:

1. **Dependencias irresolubles:** El paquete `theftdeterrentclient` exige dependencias deprecadas, rompiendo la base de datos de `apt`.
2. **Crash silencioso del cliente:** Los binarios están enlazados estáticamente contra `libpython2.7`, librería eliminada de los repositorios actuales.

> **Nota sobre parches previos:**  
> El parche comunitario provisto por [Maxelslasarte](https://huayra.educar.gob.ar/ayuda/?qa=user/Maxelslasarte) corrige los *metadatos* (cambiando la dependencia a Python 3), pero no soluciona el crash de los *binarios* (que siguen requiriendo la librería original en tiempo de ejecución).

---

## La Solución

La solución consta de un instalador automatizado (`install.sh`) diseñado para resolver todos los conflictos de dependencias de forma dinámica:

* **Instalación de dependencias legacy:** Obtiene `libpython2.7` directamente del repositorio `universe` o mediante un fallback temporal al archivo de Ubuntu Jammy.
* **Aplicación inteligente de parches:** Despliega los metadatos parcheados de Guardian únicamente si el sistema carece de un entorno Python 2 nativo.
* **Integración del sistema:** Crea los enlaces simbólicos necesarios para disponer del comando `theftdeterrentclient` globalmente.

---

## Instalación

### Linux (Debian, Ubuntu, Linux Mint, Kali, Huayra 6.5+)

Para instalar, clonar el repositorio y ejecutar el script automatizado con privilegios de administrador:

```bash
git clone https://github.com/lfmen/TheftDeterrent.git
cd TheftDeterrent
sudo bash install.sh
```

*(Para instalaciones manuales o auditoría, los paquetes `.deb` se encuentran aislados en el directorio `deb/`).*

### Huayra 5 / 6

Proceder con la instalación convencional a través del gestor de paquetes (Synaptic o `apt` instalando el meta-paquete `theft`). Si ocurren conflictos de dependencias, recurrir al método de instalación de Debian descrito arriba.

### Windows 10 / 11

1. Ejecutar el instalador `windows/Theft Derrent Guardian.exe` *(asegurarse de habilitar la opción de desinstalación sin contraseña)*.
2. Ejecutar el instalador `windows/Theft Derrent Agent.exe`.
3. Reiniciar el sistema operativo.

---

## Post-Instalación

1. Iniciar el demonio o cliente ejecutando `theftdeterrentclient`.
2. Navegar al panel de **Configuración**.
3. Configurar el servidor correspondiente:
   * Red Juana Manso: `citd.dgp.educ.ar`
   * Otros equipos: `tds.educacion.gob.ar`

---

## Referencias y Repositorios

* [Jotalea/TheftDeterrent](https://github.com/Jotalea/TheftDeterrent) — Repositorio y documentación original.
* [Parche de Maxelslasarte](https://huayra.educar.gob.ar/ayuda/?qa=user/Maxelslasarte) — Adaptación de metadatos de Guardian.
* [HuayraLinux/theftdeterrent6](https://github.com/HuayraLinux/theftdeterrent6) — Paquetización oficial para entornos Huayra 6.

---

## Licencia

El cliente de Theft Deterrent es propiedad del Ministerio de Educación de la República Argentina. 
El instalador y las herramientas de despliegue de este repositorio se distribuyen bajo la [Licencia MIT](LICENSE).
