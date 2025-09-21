#!/bin/bash
OPENSSL_CONF="" tagui AutoPapper.tag IN/xpaths.csv -t

python generar_prompts.py OUT/AutoPapper.csv OUT/Prompts.csv