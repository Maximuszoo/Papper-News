#!/usr/bin/env python3
"""
generar_prompts.py

Lee un CSV con columnas: name, Description, URL
Agrupa registros en lotes (por defecto 10) y genera un CSV de salida con
una columna 'prompt' donde cada fila contiene el prompt (una sola línea)
que le darás a la IA para resumir esos papers (máx 3 renglones por paper,
estructura con Título, Resumen y Descripción).

Uso:
    python generar_prompts.py input.csv output.csv
    python generar_prompts.py input.csv output.csv --batch-size 10

"""

import csv
import argparse
import os
import sys
import html
import re

def clean_text_one_line(text: str) -> str:
    """Elimina saltos de línea y espacios múltiples, y recorta."""
    if text is None:
        return ""
    # Convertir entidades HTML si las hubiera
    text = html.unescape(text)
    # Reemplazar cualquier newline o retorno por un espacio
    text = re.sub(r'[\r\n]+', ' ', text)
    # Reemplazar múltiples espacios por uno
    text = re.sub(r'\s+', ' ', text)
    return text.strip()

def build_prompt_for_batch(batch, max_per_paper_lines=3):
    """
    batch: lista de dicts con keys: name, Description, URL
    Devuelve un string (una línea) con la instrucción + los papers formateados.
    """
    n = len(batch)
    instruction = (
        f"Resume los siguientes {n} papers científicos en formato atractivo para WhatsApp. "
        f"Para cada paper traduce el título al español y escribe: Título en Español, Resumen (máximo {max_per_paper_lines} líneas) y Puntos Clave. "
        "Usa emojis apropiados (🤖 para IA, 💻 para software, 🔒 para seguridad, 🧬 para investigación, etc.). "
        "IMPORTANTE: NO saludes, NO agregues introducción, NO digas 'Aquí tienes' o similares. Ve directo al grano y empieza inmediatamente con el primer paper. "
        "Formato requerido por paper: "
        "🔬 **Título en Español:** <traducción del título> "
        "📝 **Resumen:** <máximo 3 líneas explicando el contenido> "
        "🎯 **Puntos Clave:** <aspectos más importantes> "
        "🔗 **Enlace:** <URL> "
        "Separa cada paper con líneas y haz que se vea atractivo para compartir. "
        "A continuación vienen los papers:"
    )

    entries = []
    for idx, row in enumerate(batch, start=1):
        title = clean_text_one_line(row.get('name', '') or row.get('title', ''))
        desc = clean_text_one_line(row.get('Description', '') or row.get('abstract', ''))
        url = clean_text_one_line(row.get('URL', ''))
        entry = f"{idx}. Título Original: {title} | Descripción: {desc} | URL: {url}"
        entries.append(entry)

    # Unir todo en UNA LÍNEA separando papers con " ||| " para mayor claridad
    joined_entries = " ||| ".join(entries)
    prompt = instruction + " " + joined_entries
    return prompt

def read_input_csv(path):
    """Lee el CSV de entrada y devuelve la lista de filas (dicts)."""
    rows = []
    with open(path, newline='', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        # Validación básica de columnas (no fatal, solo advertencia si faltan)
        expected = {'name', 'Description', 'URL'}
        found = set(reader.fieldnames or [])
        missing = expected - found
        if missing:
            # no interrumpe; asume que user tiene columnas con nombres parecidos
            print(f"Advertencia: columnas esperadas ausentes en input CSV: {missing}. Continuando...", file=sys.stderr)
        for r in reader:
            rows.append(r)
    return rows

def write_output_csv(prompts, out_path):
    """Escribe un CSV con una sola columna 'prompt'."""
    with open(out_path, 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f, quoting=csv.QUOTE_MINIMAL)
        writer.writerow(['prompt'])
        for p in prompts:
            writer.writerow([p])

def chunk_list(lst, n):
    """Divide la lista en chunks de tamaño n (el último puede ser más pequeño)."""
    for i in range(0, len(lst), n):
        yield lst[i:i+n]

def main():
    parser = argparse.ArgumentParser(description="Genera prompts en lotes desde un CSV de papers.")
    parser.add_argument('input_csv', help='Ruta al CSV de entrada (con columnas name, Description, URL).')
    parser.add_argument('output_csv', help='Ruta al CSV de salida que contendrá la columna "prompt".')
    parser.add_argument('--batch-size', '-b', type=int, default=10, help='Cantidad de papers por prompt (default 10).')
    parser.add_argument('--max-lines', type=int, default=3, help='Máximo de renglones por resumen pedido a la IA (default 3).')
    args = parser.parse_args()

    if not os.path.isfile(args.input_csv):
        print(f"Error: no se encuentra el archivo de entrada: {args.input_csv}", file=sys.stderr)
        sys.exit(1)

    rows = read_input_csv(args.input_csv)
    if not rows:
        print("No hay registros en el CSV de entrada. Abortando.", file=sys.stderr)
        sys.exit(1)

    prompts = []
    for batch in chunk_list(rows, args.batch_size):
        prompt = build_prompt_for_batch(batch, max_per_paper_lines=args.max_lines)
        prompts.append(prompt)

    write_output_csv(prompts, args.output_csv)
    print(f"Generados {len(prompts)} prompts en {args.output_csv}")

if __name__ == '__main__':
    main()
