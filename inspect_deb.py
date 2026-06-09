import tarfile
import subprocess
import io
import os

# Directorio base: donde está este script
base_dir = os.path.dirname(os.path.abspath(__file__))

files = [
    'theftdeterrentclient-lib_6.0.0.11.huayra10_amd64.deb',
    'theftdeterrentclient_6.0.0.11.huayra10_amd64.deb',
    'theftdeterrentdaemon_6.0.0.11.huayra10_amd64.deb',
    'theftdeterrentguardian_6.0.0.11.huayra10_amd64.deb',
    'theftdeterrentguardian_6.0.0.11.debian10_amd64.deb',
]

for f in files:
    deb_path = os.path.join(base_dir, f)
    if not os.path.exists(deb_path):
        print(f"Archivo no encontrado, omitiendo: {f}")
        continue

    print(f'\n--- {f} ---')
    tar_out = subprocess.check_output(['tar', '-tf', deb_path]).decode('utf-8')

    if 'control.tar.gz' in tar_out:
        control_tar = subprocess.check_output(['tar', '-xf', deb_path, '-O', 'control.tar.gz'])
    else:
        control_tar = subprocess.check_output(['tar', '-xf', deb_path, '-O', 'control.tar.xz'])

    with tarfile.open(fileobj=io.BytesIO(control_tar)) as tf:
        try:
            control_file = tf.extractfile('./control')
            print(control_file.read().decode('utf-8'))
        except Exception as e:
            print(e)
