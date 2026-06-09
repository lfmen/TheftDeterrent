#!/bin/bash

# Salir si algo sale mal
set -e

# Variables predeterminadas
URL_BASE="https://raw.githubusercontent.com/lfmen/TheftDeterrent/main/deb"
# Directorio donde está el script (para buscar los .deb locales)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FILES=(
    "theftdeterrentclient-lib_6.0.0.11.huayra10_amd64.deb"
    "theftdeterrentclient_6.0.0.11.huayra10_amd64.deb"
    "theftdeterrentdaemon_6.0.0.11.huayra10_amd64.deb"
    "theftdeterrentguardian_6.0.0.11.huayra10_amd64.deb"
)
PATCHED_FILE="theftdeterrentguardian_6.0.0.11.debian10_amd64.deb"
DEFAULT_DIR="$HOME/tda"
LOG_FILE="tda_install_log.txt"
SCRIPT_VERSION=2
USE_LOG=true
CLEANUP=true
INSTALL=true
RUN_AFTER_INSTALL=false

# Función para manejar errores
handle_error() {
    echo "Error en el paso: $1" >&2
    exit 1
}

# Función para verificar dependencias de Python para guardian
check_python() {
    if dpkg -s python >/dev/null 2>&1 || command -v python2 >/dev/null 2>&1 || command -v python2.6 >/dev/null 2>&1; then
        echo "Python 2 detectado. Se instalará la versión estándar de guardian."
        NEED_PATCH="false"
    else
        echo "Python 2 no detectado. Se utilizará el parche de guardian para Python 3."
        NEED_PATCH="true"
    fi
}

# Función de ayuda
show_help() {
    echo "Uso: $0 [OPCIONES]"
    echo "Opciones:"
    echo "  --solo-descarga, --download-only, -D   No instala el programa, sólo descarga los archivos de instalación"
    echo "  --help, -H                             Muestra esta ayuda y no ejecuta el resto del script"
    echo "  --log <archivo>, -L <archivo>          Loguea los resultados al archivo especificado en lugar de $LOG_FILE"
    echo "  --dir <directorio>, -D <directorio>    Cambia el directorio a usar por el especificado"
    echo "  --mirror <URL>, -M <URL>               Permite usar un servidor distinto para descargar los archivos"
    echo "  --no-limpiar, --no-cleanup             Después de la instalación, no borra los archivos .deb que se usaron"
    echo "  --no-log                               Deshabilita el logging a $LOG_FILE"
    echo "  --ejecutar, -E                         Ejecuta el programa después de la instalación"
    exit 0
}

# Procesar parámetros opcionales
process_parameters() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --solo-descarga | --download-only | -D)
                INSTALL=false
                CLEANUP=false
                ;;
            --no-limpiar | --no-cleanup)
                CLEANUP=false
                ;;
            --help | -H)
                show_help
                ;;
            --no-log)
                USE_LOG=false
                ;;
            --log | -L)
                shift
                LOG_FILE="$1"
                ;;
            --dir | -D)
                shift
                DIR="$1"
                validate_directory "$DIR"
                ;;
            --mirror | -M)
                shift
                URL_BASE="$1"
                ;;
            --ejecutar | -E)
                RUN_AFTER_INSTALL=true
                ;;
            *)
                echo "Parámetro desconocido: $1"
                exit 1
                ;;
        esac
        shift
    done
}

# Función para validar y crear el directorio si no existe
validate_directory() {
    local dir="$1"
    if ! [[ -d "$dir" ]]; then
        echo "Creando el directorio $dir..."
        mkdir -p "$dir" || handle_error "No se pudo crear el directorio $dir"
    fi
    DEFAULT_DIR="$dir"
}

# Verificar si se ejecuta como root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        handle_error "Este script tiene que ejecutarse como root."
    fi
}

# Verificar dependencias
check_dependencies() {
    echo "Verificando dependencias..."
    dpkg -s wget &> /dev/null || (apt-get update && apt-get install -y wget) || handle_error "No se pudo instalar wget"
    dpkg -s dpkg &> /dev/null || handle_error "dpkg no está instalado"
}

# Instalar libpython2.7
install_python_lib() {
    if dpkg -s libpython2.7 >/dev/null 2>&1; then
        echo "Librería libpython2.7 ya está instalada."
        return 0
    fi

    echo "La librería libpython2.7 no está instalada. Es necesaria para el cliente gráfico."

    # Intentar habilitar el repositorio 'universe' (contiene libpython2.7 en Ubuntu 22.04 / Mint 21)
    apt-get install -y software-properties-common >/dev/null 2>&1 || true
    add-apt-repository universe -y >/dev/null 2>&1 || true
    apt-get update -qq

    if apt-cache show libpython2.7 >/dev/null 2>&1; then
        echo "Instalando libpython2.7 desde los repositorios oficiales..."
        apt-get install -y libpython2.7 || handle_error "No se pudo instalar libpython2.7"
    else
        # Fallback avanzado para Linux Mint 22 / Ubuntu 24.04 (donde se eliminó python2.7)
        local jammy_list="/etc/apt/sources.list.d/python2-jammy-temp.list"
        # Garantizar que el repo temporal se limpie aunque el script falle
        trap "rm -f '$jammy_list'; apt-get update -qq 2>/dev/null || true" EXIT

        echo "libpython2.7 no está en los repositorios. Agregando repositorio antiguo temporalmente (Jammy)..."
        echo "deb http://archive.ubuntu.com/ubuntu/ jammy universe" > "$jammy_list"
        apt-get update -qq

        echo "Instalando libpython2.7 y sus dependencias..."
        apt-get install -y libpython2.7 || handle_error "No se pudo instalar libpython2.7 desde el repositorio de Jammy"

        echo "Limpiando repositorio temporal..."
        rm -f "$jammy_list"
        apt-get update -qq

        # Desactivar el trap ya que limpiamos manualmente con éxito
        trap - EXIT
    fi
}

# Verificar espacio en disco
check_disk_space() {
    local required_space_mb=100
    local available_space_mb=$(df "$DEFAULT_DIR" | tail -1 | awk '{print $4}')
    available_space_mb=$((available_space_mb / 1024))

    if (( available_space_mb < required_space_mb )); then
        handle_error "No tenés suficiente espacio. Necesitás al menos ${required_space_mb}MB más."
    fi
}

# Cambiar al directorio
change_directory() {
    cd "$DEFAULT_DIR" || handle_error "No se puede usar el directorio $DEFAULT_DIR"
}

# Descargar o copiar archivos .deb
download_files() {
    for FILE in "${FILES[@]}"; do
        if [ "$FILE" == "theftdeterrentguardian_6.0.0.11.huayra10_amd64.deb" ] && [ "$NEED_PATCH" == "true" ]; then
            FILE=$PATCHED_FILE
        fi

        if [ -f "$FILE" ]; then
            echo "Ya tenés el archivo $FILE en el directorio de trabajo."
        elif [ -f "$SCRIPT_DIR/deb/$FILE" ]; then
            echo "Copiando $FILE desde la carpeta local (deb/)..."
            cp "$SCRIPT_DIR/deb/$FILE" "$FILE"
        else
            echo "Descargando $FILE desde internet..."
            wget "$URL_BASE/$FILE" || handle_error "No se pudo descargar $FILE desde $URL_BASE"
            chown "$USER:$USER" "$FILE"  # Cambiar propietario y grupo al usuario actual
            chmod 644 "$FILE"            # Establecer permisos rw-r--r--
        fi
    done
}

# Instalar archivos .deb
install_files() {
    for FILE in "${FILES[@]}"; do
        if [ "$FILE" == "theftdeterrentguardian_6.0.0.11.huayra10_amd64.deb" ] && [ "$NEED_PATCH" == "true" ]; then
            FILE=$PATCHED_FILE
        fi

        echo "Instalando $FILE..."
        dpkg -i "$FILE" || handle_error "No se pudo instalar $FILE"
    done
}

# Agregar al PATH
add_to_path() {
    local bin_path="/usr/local/bin"
    # El paquete instala en /opt/TheftDeterrentclient (c minúscula en 'client')
    local script_path="/opt/TheftDeterrentclient/client/Theft_Deterrent_client.autorun"

    if [[ -f "$script_path" ]]; then
        echo "Agregando 'theftdeterrentclient' al PATH..."
        ln -sf "$script_path" "$bin_path/theftdeterrentclient" || handle_error "No se pudo crear el enlace simbólico"
        echo "El comando 'theftdeterrentclient' ahora está disponible en el PATH."
    else
        echo "Advertencia: no se encontró el autorun en $script_path, omitiendo el enlace simbólico."
    fi
}

# Ejecutar el programa
run_program() {
    echo "Ejecutando el programa..."
    /opt/TheftDeterrentclient/client/Theft_Deterrent_client.autorun || handle_error "No se pudo ejecutar el programa"
}

# Limpiar archivos .deb
clean_up() {
    echo "Limpiando archivos .deb..."
    rm -f *.deb || handle_error "No se pudo borrar los archivos .deb"
}

# Iniciar logging
init_logging() {
    if $USE_LOG; then
        echo "Instalando..." > "$LOG_FILE"
    fi
}

# Procesar parámetros (si se pasan; sin argumentos = instalación normal)
if [[ $# -gt 0 ]]; then
    process_parameters "$@"
fi

# Ejecutar funciones
check_root
check_dependencies
install_python_lib
validate_directory "$DEFAULT_DIR"
check_disk_space
change_directory
init_logging
check_python
download_files

if [[ "$INSTALL" == true ]]; then
    install_files
    add_to_path
fi

if [[ "$RUN_AFTER_INSTALL" == true ]]; then
    run_program
fi

if [[ "$CLEANUP" == true ]]; then
    clean_up
fi

# Finalizar
if $USE_LOG; then
    echo "Se instaló el Theft Deterrent." >> "$LOG_FILE"
    echo "Podés leer las instrucciones de post-instalación en https://github.com/lfmen/TheftDeterrent#post-instalación" >> "$LOG_FILE"
else
    echo "Se instaló el Theft Deterrent."
    echo "Podés leer las instrucciones de post-instalación en https://github.com/lfmen/TheftDeterrent#post-instalación"
fi

exit 0
