import tarfile
import subprocess
import io
import os

# Directorio base: donde está este script
base_dir = os.path.dirname(os.path.abspath(__file__))
os.makedirs(os.path.join(base_dir, 'extracted_deb_all'), exist_ok=True)

files = [
    'theftdeterrentclient-lib_6.0.0.11.huayra10_amd64.deb',
    'theftdeterrentclient_6.0.0.11.huayra10_amd64.deb',
    'theftdeterrentdaemon_6.0.0.11.huayra10_amd64.deb',
    'theftdeterrentguardian_6.0.0.11.debian10_amd64.deb',
]

for f in files:
    deb_path = os.path.join(base_dir, f)
    print(f"Extrayendo {f}...")
    tar_out = subprocess.check_output(['tar', '-tf', deb_path]).decode('utf-8').splitlines()
    data_file = [n.strip() for n in tar_out if 'data.tar' in n][0]
    data_tar = subprocess.check_output(['tar', '-xf', deb_path, '-O', data_file])
    with tarfile.open(fileobj=io.BytesIO(data_tar)) as tf:
        tf.extractall(os.path.join(base_dir, 'extracted_deb_all'))

print("Extracción completa.")
