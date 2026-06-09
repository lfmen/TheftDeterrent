import tarfile
import subprocess
import io
import os

# Directorio base: donde está este script
base_dir = os.path.dirname(os.path.abspath(__file__))
os.makedirs(os.path.join(base_dir, 'extracted_deb'), exist_ok=True)

f = 'theftdeterrentguardian_6.0.0.11.debian10_amd64.deb'
deb_path = os.path.join(base_dir, f)

tar_out = subprocess.check_output(['tar', '-tf', deb_path]).decode('utf-8').splitlines()
data_file = [n.strip() for n in tar_out if 'data.tar' in n][0]
print(f"Extrayendo {data_file} desde {f}...")

data_tar = subprocess.check_output(['tar', '-xf', deb_path, '-O', data_file])
with tarfile.open(fileobj=io.BytesIO(data_tar)) as tf:
    tf.extractall(os.path.join(base_dir, 'extracted_deb'))

print("Extracción del guardian completa.")
