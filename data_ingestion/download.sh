#!/bin/bash

# Vérification du nombre d'arguments
if [ "$#" -ne 2 ]; then
  echo "Usage: bash download.sh YEAR MONTH"
  exit 1
fi

YEAR=$1
MONTH=$2
MONTH2=$(printf "%02d" $MONTH)

# URL de base des fichiers à télécharger
BTS=https://transtats.bts.gov/PREZIP
BASEURL="${BTS}/On_Time_Reporting_Carrier_On_Time_Performance_1987_present"

# Dossier temporaire pour stocker le fichier ZIP
TMPDIR=$(mktemp -d)
ZIPFILE=${TMPDIR}/${YEAR}_${MONTH2}.zip

# Téléchargement du fichier ZIP
echo "Téléchargement du fichier pour $YEAR-$MONTH2 ..."
curl -s -o $ZIPFILE ${BASEURL}_${YEAR}_${MONTH}.zip

# Vérification si le fichier a bien été téléchargé
if [ ! -f "$ZIPFILE" ]; then
  echo "Échec du téléchargement pour $YEAR-$MONTH2"
  rm -rf $TMPDIR
  exit 1
fi

# Décompression dans le dossier temporaire
unzip -q -d $TMPDIR $ZIPFILE

# Renommage et déplacement du fichier CSV
mv $TMPDIR/*.csv ./${YEAR}${MONTH2}.csv
echo "Fichier enregistré sous : ${YEAR}${MONTH2}.csv"

# Nettoyage
rm -rf $TMPDIR
