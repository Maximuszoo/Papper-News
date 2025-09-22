#!/bin/bash
OPENSSL_CONF="" tagui AutoPapper.tag IN/xpaths.csv -t

python generar_prompts.py OUT/AutoPapper.csv OUT/Prompts.csv

OPENSSL_CONF="" tagui AIOverview.tag OUT/Prompts.csv -t

rm OUT/Prompts.csv OUT/AutoPapper.csv