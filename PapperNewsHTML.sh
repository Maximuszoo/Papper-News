#!/bin/bash
OPENSSL_CONF="" tagui AutoPapper.tag IN/xpaths.csv -t

python generar_prompts.py OUT/AutoPapper.csv OUT/Prompts.csv

OPENSSL_CONF="" tagui AICSV.tag OUT/Prompts.csv -t

python generar_portal.py OUT/ProcessedPapers.csv portal_noticias.html

rm OUT/Prompts.csv OUT/AutoPapper.csv OUT/ProcessedPapers.csv