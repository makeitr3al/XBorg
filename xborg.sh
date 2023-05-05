import json
import os
import subprocess
import requests

# Setze die Zielsprache für die Übersetzung
target_lang = 'DE'

# Extrahiere Informationen aus der Payload
payload = json.loads(request.data)
repo_name = payload['repository']['name']
repo_url = payload['repository']['clone_url']
branch = payload['ref'].split('/')[-1]

# Konstruiere den Pfad zum Zielverzeichnis
target_dir = os.path.join(os.getcwd(), repo_name)

# Klone das Repository oder aktualisiere es
if os.path.exists(target_dir):
    subprocess.run(['git', 'fetch'], cwd=target_dir)
else:
    subprocess.run(['git', 'clone', '--branch', branch, repo_url, target_dir])

# Übersetze die Markdown-Dateien und speichere sie im Ziel-Repository
for root, dirs, files in os.walk(target_dir):
    for file in files:
        if file.endswith('.md'):
            # Konstruiere den Pfad zur Markdown-Datei
            md_file_path = os.path.join(root, file)

            # Konvertiere Markdown-Datei in Text-Datei
            txt_file_path = os.path.splitext(md_file_path)[0] + '.txt'
            subprocess.run(['pandoc', '-f', 'markdown', '-t', 'plain', md_file_path, '-o', txt_file_path])

            # Lese Text-Datei und übersetze sie
            with open(txt_file_path, 'r') as f:
                text = f.read()
                response = requests.post('https://api-free.deepl.com/v2/translate', data={
                    'auth_key': 'e4275429-3a26-63f6-f8bc-d3d2bd80f174:fx',
                    'text': text,
                    'target_lang': target_lang
                })

            # Schreibe die übersetzte Text-Datei zurück in die Markdown-Datei
            with open(txt_file_path, 'w') as f:
                f.write(response.json()['translations'][0]['text'])
            subprocess.run(['pandoc', '-f', 'plain', '-t', 'markdown', txt_file_path, '-o', md_file_path])
            os.remove(txt_file_path)
