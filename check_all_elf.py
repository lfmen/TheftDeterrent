import os
import re

# Directorio donde están los .deb extraídos (relativo al script)
search_dir = os.path.join(os.path.dirname(__file__), 'extracted_deb_all')

for root, _, files in os.walk(search_dir):
    for name in files:
        path = os.path.join(root, name)
        with open(path, 'rb') as f:
            data = f.read()
            # Verificar si es un binario ELF
            if data.startswith(b'\x7fELF'):
                so_files = set(re.findall(rb'lib[a-zA-Z0-9_\-]+\.so[\.0-9]*', data))
                print(f"ELF: {os.path.relpath(path, search_dir)}")
                print("  Dependencias:", [s.decode('utf-8') for s in so_files])
