import sys
import re

def parse_elf(filename):
    with open(filename, 'rb') as f:
        magic = f.read(4)
        if magic != b'\x7fELF':
            print(f"No es un archivo ELF: {magic}")
            return

        f.seek(0)
        data = f.read()

        so_files = set(re.findall(rb'lib[a-zA-Z0-9_\-]+\.so[\.0-9]*', data))
        print("Posibles librerías compartidas necesarias:")
        for so in sorted(so_files):
            print(" ", so.decode('utf-8'))

        print("\nReferencias a Python encontradas:")
        py_refs = set(re.findall(rb'python[a-zA-Z0-9_\-\.]+', data))
        for py in sorted(py_refs):
            print(" ", py.decode('utf-8'))

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Uso: python check_elf.py <ruta_al_binario_ELF>")
        print("Ejemplo: python check_elf.py extracted_deb/opt/TheftDeterrentclient/guardian/Theft_Deterrent_guardian")
        sys.exit(1)
    parse_elf(sys.argv[1])
