#!/bin/bash

# Konfiguration
source_dir="https://github.com/makeitr3al/XBorg"
target_dir="https://github.com/makeitr3al/Translate"
api_key="your_api_key_here"
translate_api="deepl" # "deepl" oder "google"

# Wechsle in das Verzeichnis, in dem das geklonte Repository liegt
cd $source_dir

# Klone das Repository, falls es noch nicht existiert
if [ ! -d ".git" ]; then
  git clone https://github.com/makeitr3al/XBorg .
fi

# Übersetze Markdown-Dateien mit der DeepL-API oder Google Translate API
if [ $translate_api = "deepl" ]; then
  translate_cmd="curl -s -H \"Authorization: DeepL-Auth-Key $e4275429-3a26-63f6-f8bc-d3d2bd80f174:fx" -d text=\"{text}\" -d target_lang=en https://api-free.deepl.com/v2/translate"
elif [ $translate_api = "google" ]; then
  translate_cmd="curl -s -X POST -H \"Content-Type: application/json\" -H \"Authorization: Bearer $api_key\" --data-raw '{\"source\":\"de\", \"target\":\"en\", \"q\":[\"{text}\"]}' \"https://translation.googleapis.com/language/translate/v2\""
fi

for file in *.md; do
  name=$(basename $file .md)
  html_text=$(pandoc -f markdown -t html $file)
  translated_text=$(echo $html_text | tr '\n' ' ' | sed 's/"/\\"/g')
  translated_text=$(eval echo "$translate_cmd")
  translated_html=$(echo $translated_text | jq -r '.translations[].text' | tr -d '\n' | sed 's/\\/\\\\/g')
  translated_md=$(pandoc -f html -t markdown $translated_html)
  echo $translated_md > $target_dir/$name.md
done

# Commit und Push der Änderungen im Ziel-Repository
cd $target_dir
git add .
git commit -m "Automatisches Update der übersetzten Markdown-Dateien"
git push
