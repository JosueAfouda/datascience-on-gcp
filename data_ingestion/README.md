# 🧭 Problématique du Projet

Dans le cadre de ce projet, nous cherchons à **prendre une décision informée quant à l'annulation ou non d'un rendez-vous professionnel**, en nous basant sur la **probabilité d'arrivée à l'heure d'un vol**. Le contexte est celui d'un voyageur qui doit décider, **avant l'arrivée de son vol**, s’il est préférable de maintenir ou d’annuler une réunion planifiée à destination.

La règle de décision adoptée est la suivante :
➡️ **Annuler la réunion si la probabilité que le vol arrive à moins de 15 minutes de retard est inférieure à 70%.**

Pour modéliser cette probabilité de ponctualité, nous utiliserons des **données historiques sur les vols** disponibles publiquement via le [Bureau of Transportation Statistics (BTS)](https://www.transtats.bts.gov/) des États-Unis. Ces données, collectées depuis 1987, décrivent de manière détaillée les performances des compagnies aériennes en matière de retards à l’arrivée. Le jeu de données utilisé, appelé [Airline On-Time Performance Data](https://www.bts.gov/topics/airline-time-tables), a été conçu précisément pour mesurer et surveiller la ponctualité des vols.

Ce projet vise donc à :

* Estimer la **probabilité d’arrivée à l’heure d’un vol donné** à partir de ses caractéristiques (compagnie, aéroport, météo, heure de départ, etc.),
* Et **automatiser la prise de décision** d’annulation d’un rendez-vous sur la base de cette estimation probabiliste.

---

# Data Ingestion

---

## ✈️ Description des colonnes du dataset (retards de vols)

### 📅 Informations temporelles

* **Year** : Année du vol (ex. 2015)
* **Quarter** : Trimestre (1 à 4)
* **Month** : Mois (1 à 12)
* **DayofMonth** : Jour du mois (1 à 31)
* **DayOfWeek** : Jour de la semaine (1 = Lundi, 7 = Dimanche)
* **FlightDate** : Date complète du vol (`YYYY-MM-DD`)

### 🏢 Compagnie aérienne

* **Reporting\_Airline** : Code transporteur (ex. "WN" pour Southwest Airlines)
* **DOT\_ID\_Reporting\_Airline** : Identifiant unique attribué par le Department of Transportation
* **IATA\_CODE\_Reporting\_Airline** : Code IATA (souvent identique à `Reporting_Airline`)
* **Tail\_Number** : Immatriculation de l'avion
* **Flight\_Number\_Reporting\_Airline** : Numéro de vol tel que rapporté par la compagnie

### 🛫 Aéroport de départ (origine)

* **OriginAirportID** : Identifiant unique de l’aéroport d’origine
* **OriginAirportSeqID** : Identifiant séquentiel pour l’aéroport d’origine
* **OriginCityMarketID** : Identifiant du marché aérien de la ville d’origine
* **Origin** : Code IATA de l’aéroport (ex. "CMH" pour Columbus)
* **OriginCityName** : Nom complet de la ville d’origine
* **OriginState** : Code de l’État (ex. "OH")
* **OriginStateFips** : Code FIPS de l’État
* **OriginStateName** : Nom complet de l’État
* **OriginWac** : Code WAC (World Area Code)

### 🛬 Aéroport de destination

* **DestAirportID** : Identifiant unique de l’aéroport de destination
* **DestAirportSeqID** : Identifiant séquentiel de l’aéroport de destination
* **DestCityMarketID** : Identifiant du marché de la ville de destination
* **Dest** : Code IATA de destination
* **DestCityName** : Nom complet de la ville de destination
* **DestState** : Code État destination
* **DestStateFips** : Code FIPS
* **DestStateName** : Nom complet de l’État
* **DestWac** : Code WAC

### 🕰️ Horaires et retards

* **CRSDepTime** : Heure planifiée de départ (au format HHMM)

* **DepTime** : Heure réelle de départ

* **DepDelay** : Délai de départ (en minutes ; peut être négatif)

* **DepDelayMinutes** : Délai de départ (valeurs < 0 mises à 0)

* **DepDel15** : 1 si le vol a eu ≥15 min de retard au départ, 0 sinon

* **DepartureDelayGroups** : Groupe de retard (catégorie de -2 à 12)

* **DepTimeBlk** : Plage horaire du départ (ex. "0600-0659")

* **TaxiOut** : Temps de roulage entre le décollage et la sortie du tarmac (en min)

* **WheelsOff** : Heure à laquelle l'avion a quitté le sol

* **WheelsOn** : Heure à laquelle l’avion a atterri

* **TaxiIn** : Temps de roulage après l'atterrissage jusqu'à la porte

* **CRSArrTime** : Heure prévue d’arrivée

* **ArrTime** : Heure réelle d’arrivée

* **ArrDelay** : Délai d’arrivée (en min, négatif si en avance)

* **ArrDelayMinutes** : Retard d’arrivée (valeurs < 0 mises à 0)

* **ArrDel15** : 1 si ≥15 min de retard à l’arrivée, 0 sinon

* **ArrivalDelayGroups** : Groupe de retard à l’arrivée (de -2 à 12)

* **ArrTimeBlk** : Plage horaire d’arrivée prévue

### 🚫 Annulations et déroutements

* **Cancelled** : 1 si vol annulé, 0 sinon

* **CancellationCode** : Raison de l’annulation :

  * A = transporteur
  * B = météo
  * C = système national de l’espace aérien (NAS)
  * D = sécurité

* **Diverted** : 1 si le vol a été dérouté, 0 sinon

### ⏱️ Durées

* **CRSElapsedTime** : Durée planifiée du vol (en minutes)
* **ActualElapsedTime** : Durée réelle
* **AirTime** : Temps de vol effectif (exclut taxiing)
* **Flights** : Nombre de vols (généralement 1)
* **Distance** : Distance en miles
* **DistanceGroup** : Groupe de distance (1 = 1-250 miles, ..., 11 = >2250 miles)

### 🕵️‍♀️ Retards par cause (en min)

* **CarrierDelay** : Retard imputable à la compagnie
* **WeatherDelay** : Retard causé par la météo
* **NASDelay** : Retard dû au système aérien (trafic, contrôles, etc.)
* **SecurityDelay** : Retard lié à la sécurité
* **LateAircraftDelay** : Retard causé par l’arrivée tardive d’un avion précédent

### 🧭 Diversion (détail si le vol a été dérouté)

* **DivAirportLandings** : Nombre d’atterrissages dans des aéroports alternatifs
* **Div1Airport**, ..., **Div5Airport** : Aéroports de déroutement (si applicable)
* **Div1WheelsOn**, ..., **Div5WheelsOn** : Heure d’atterrissage dans l’aéroport dérouté
* **Div1TotalGTime** : Temps total au sol lors du déroutement
* **Div1TailNum** : Numéro d'immatriculation de l'appareil utilisé dans la diversion

---


## 📥 Exemple de téléchargement

Pour récupérer les données d’un mois spécifique depuis le site officiel du Bureau of Transportation Statistics (BTS), on peut utiliser les commandes suivantes en ligne de commande :

```bash
# Définition de l'URL de base pointant vers le répertoire des fichiers ZIP
BTS=https://transtats.bts.gov/PREZIP
BASEURL="${BTS}/On_Time_Reporting_Carrier_On_Time_Performance_1987_present"

# On précise l'année et le mois souhaités (ici mars 2015)
YEAR=2015
MONTH=3

# Téléchargement du fichier ZIP correspondant à mars 2015
curl -k -o temp.zip ${BASEURL}_${YEAR}_${MONTH}.zip
```

* `curl -k -o temp.zip ...` : télécharge le fichier ZIP contenant les données brutes pour le mois spécifié.

  * `-k` : ignore les erreurs de certificat SSL (utile si le site utilise un certificat auto-signé).
  * `-o temp.zip` : enregistre le fichier sous le nom `temp.zip`.

Ensuite, pour décompresser le fichier ZIP téléchargé :

```bash
unzip temp.zip
```

Cela extrait un fichier `.csv` contenant les données des vols du mois sélectionné.

On peut ensuite afficher un aperçu des premières lignes du fichier CSV avec :

```bash
head -5 *.csv
```

Cette commande permet de :

* repérer le nom exact du fichier CSV,
* visualiser les 5 premières lignes pour comprendre la structure des données (noms de colonnes + quelques exemples).

Ce processus est simple et efficace pour explorer les données mois par mois directement depuis le terminal.

---


## 📦 Automatisation du téléchargement mensuel des données

### ▶️ Exemple pour un mois donné : téléchargement de `201503.csv`

Pour récupérer les données de performance des vols du mois de **mars 2015**, on peut automatiser le téléchargement avec une série de commandes bash simples :

```bash
YEAR=2015
MONTH=3
MONTH2=$(printf "%02d" $MONTH)  # Formatage du mois sur deux chiffres (ex: 03)

TMPDIR=$(mktemp -d)             # Création d’un dossier temporaire
ZIPFILE=${TMPDIR}/${YEAR}_${MONTH2}.zip

# Téléchargement du fichier ZIP depuis le site de la BTS
curl -o $ZIPFILE https://transtats.bts.gov/PREZIP/On_Time_Reporting_Carrier_On_Time_Performance_1987_present_${YEAR}_${MONTH}.zip

# Décompression dans le dossier temporaire
unzip -d $TMPDIR $ZIPFILE

# Déplacement et renommage du fichier CSV en "201503.csv"
mv $TMPDIR/*.csv ./${YEAR}${MONTH2}.csv

# Suppression du dossier temporaire
rm -rf $TMPDIR
```

Ces commandes permettent :

* d'automatiser le téléchargement du fichier compressé `.zip`,
* de l’extraire,
* de renommer proprement le fichier `.csv`,
* et de nettoyer les fichiers temporaires.

---

### 🔁 Généralisation via le script `download.sh`

Afin d’automatiser le téléchargement pour **plusieurs mois**, on a encapsulé les étapes ci-dessus dans un script bash réutilisable : `download.sh`.

```bash
bash download.sh 2015 3
```

Cela exécutera les mêmes étapes que ci-dessus, mais pour n’importe quelle **année** et **mois** donnés en paramètres.

Voici un exemple d’automatisation complète pour **télécharger tous les mois de l’année 2015** :

```bash
YEAR=2015
for MONTH in `seq 1 12`; do
   bash download.sh $YEAR $MONTH
done
```

Chaque appel à `download.sh` télécharge le fichier `YYYYMM.csv` correspondant dans le répertoire courant (par exemple : `201501.csv`, `201502.csv`, …).

---

Ce système rend le processus **simple, propre et scalable** pour tous les mois et toutes les années disponibles dans la base de données du [Bureau of Transportation Statistics](https://transtats.bts.gov/OT_Delay/OT_DelayCause1.asp?).

---

## 📊 Analyse initiale des fichiers CSV (2015)

Une fois les fichiers `2015MM.csv` téléchargés et extraits pour chaque mois, il est utile de faire une première analyse en ligne de commande pour **évaluer la structure et la taille** des données.

### 🧮 Nombre de colonnes

On peut compter rapidement le **nombre de colonnes** du fichier en regardant une ligne d’exemple (ici la première ligne de données) et en comptant les séparateurs :

```bash
head -2 201503.csv | tail -1 | sed 's/,/ /g' | wc -w
```

Ce qui donne :

```bash
81
```

👉 Le fichier contient donc **81 colonnes**, ce qui reflète la richesse des informations disponibles pour chaque vol.

### 📈 Nombre de lignes par mois

On peut aussi compter le **nombre de lignes (vols)** dans chaque fichier CSV correspondant à un mois de l’année 2015 :

```bash
wc -l *.csv
```

Sortie typique :

```
    469969 201501.csv
    429192 201502.csv
    504313 201503.csv
    485152 201504.csv
    496994 201505.csv
    503898 201506.csv
    520719 201507.csv
    510537 201508.csv
    464947 201509.csv
    486166 201510.csv
    467973 201511.csv
    479231 201512.csv
   6323404 total
```

👉 Cela représente **plus de 6 millions de vols** enregistrés en 2015 !

### ⚠️ Pourquoi c’est important ?

* Ces commandes permettent d’avoir une idée de la **taille des données à manipuler**.
* La lenteur de ces commandes en ligne de commande donne un indice sur le fait que **toute analyse “full scan” risque d’être coûteuse en temps**, surtout en local.
* On comprend dès lors l’intérêt d’utiliser des outils comme **BigQuery** ou **Spark** pour une montée en échelle efficace.

💡 *Ce genre d'analyse exploratoire simple montre à quel point quelques compétences en scripting Unix (bash, wc, sed, etc.) peuvent être précieuses au début d’un projet Data.*

---

## ☁️ Téléchargement de données vers Google Cloud Storage

### 🔎 Qu’est-ce que Google Cloud Storage (GCS) ?

**Google Cloud Storage (GCS)** est un service de stockage d’objets dans le cloud proposé par Google Cloud Platform. Il permet de stocker tout type de fichier (CSV, images, vidéos, modèles, backups, etc.) dans des *buckets* (conteneurs), un peu comme des dossiers, avec une grande durabilité et accessibilité mondiale.

Dans notre projet, nous allons utiliser GCS pour stocker les fichiers de vols (.csv) avant de les exploiter avec d’autres services comme BigQuery ou Dataflow.

---

### 🚀 Étapes de transfert des fichiers vers GCS

Voici les commandes utilisées pour créer un bucket GCS et y envoyer les fichiers CSV :

```bash
# Récupération du projet actif configuré avec gcloud
PROJECT=$(gcloud config get-value project)

# Nom du bucket = nom du projet + suffixe explicite
BUCKET=${PROJECT}-dsongcp

# Spécification de la région
REGION=us-central1

# Création du bucket de stockage dans la région spécifiée
gcloud storage buckets create gs://$BUCKET --location=$REGION

# Envoi des fichiers CSV dans un dossier 'flights/raw' du bucket
gcloud storage cp *.csv gs://$BUCKET/flights/raw
```

#### 🧠 Explications :

* `gcloud config get-value project` : récupère l'ID du projet GCP actif.
* `gcloud storage buckets create` : crée un nouveau bucket de stockage.
* `gcloud storage cp` : copie tous les fichiers CSV vers le bucket dans un dossier `flights/raw`.

📁 Au final, vos données se retrouveront dans ce chemin cloud :

```
gs://<votre-projet>-dsongcp/flights/raw/
```

Cela constitue une **étape clé de l’ingestion de données** dans le cloud : les fichiers sont prêts à être utilisés par d'autres services Google Cloud (ex. : Dataflow, BigQuery, Dataproc).

---

## 🧭 Chargement des données dans BigQuery

### 🔍 Qu’est-ce que BigQuery ?

[**BigQuery**](https://cloud.google.com/bigquery) est un *entrepôt de données* (Data Warehouse) serverless proposé par Google Cloud. Il permet de stocker et d'interroger de très grands volumes de données avec une latence très faible grâce à une architecture massivement parallèle.

BigQuery est parfaitement adapté pour des cas d’analyse de données à grande échelle comme :

* l’exploration de données brutes,
* la création de tableaux de bord,
* l’entraînement de modèles de Machine Learning,
* ou encore l’alimentation d'applications métiers.

---

### 📊 ELT vs ETL : un changement de paradigme

La pratique moderne privilégie de plus en plus l’approche **ELT (Extract - Load - Transform)** à l’ancienne méthode **ETL (Extract - Transform - Load)**.
👉 Dans ELT :

* les données sont **chargées brutes** dans le Data Warehouse,
* puis **transformées à la demande** via des requêtes SQL ou des outils spécialisés (dbt, Dataform, etc.).

Cela permet plus de flexibilité, de traçabilité et d’agilité, comme illustré ci-dessous :

![ELT diagram](./5a957722-3bd1-4588-b782-8d6ffd853843.png)

---

### 🚀 Chargement d’un fichier CSV dans BigQuery

Voici les commandes de base utilisées pour créer un dataset et charger un fichier CSV brut dans une table :

```bash
# Création d’un dataset BigQuery nommé 'dsongcp' dans la région spécifiée
bq --location=$REGION mk dsongcp

# Chargement automatique d’un fichier CSV dans une table 'flights_auto'
bq load --autodetect --source_format=CSV dsongcp.flights_auto gs://${BUCKET}/flights/raw/201501.csv
```

✅ Cette commande utilise l’option `--autodetect` pour inférer automatiquement le schéma. C’est pratique au début, mais pas recommandé en production car elle peut conduire à des erreurs ou des types incorrects.

Via la [Console Web de BigQuery](https://console.cloud.google.com/bigquery), tu peux tester une requête sur la table :

```sql
SELECT
    ORIGIN,
    AVG(DEPDELAY) AS dep_delay,
    AVG(ARRDELAY) AS arr_delay,
    COUNT(ARRDELAY) AS num_flights
FROM
    dsongcp.flights_auto
GROUP BY
    ORIGIN
ORDER BY num_flights DESC
LIMIT 10;
```

---

### 📉 Pourquoi partitionner les tables dans BigQuery ?

BigQuery facture à la requête selon le volume de données scannées. Partitionner une table, par exemple par **mois de vol (`FlightDate`)**, permet de :

* réduire considérablement le **coût des requêtes**,
* améliorer les **performances**,
* simplifier la **gestion temporelle des données**.

---

### 🧹 Rechargement avec un schéma explicite et partitionnement mensuel

Nous allons maintenant supprimer la table automatique et créer des tables partitionnées par mois avec un schéma bien défini :

```bash
bq rm -f -t dsongcp.flights_auto
touch bqload.sh
```

---

### 📜 Script `bqload.sh` — Chargement robuste et scalable

Ce script charge les 12 fichiers mensuels de l’année spécifiée dans une table partitionnée `flights_raw`, avec un schéma précis :

```bash
#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: ./bqload.sh csv-bucket-name YEAR"
    exit
fi

BUCKET=$1
YEAR=$2
SCHEMA=... # schéma complet omis ici pour lisibilité

PROJECT=$(gcloud config get-value project)
bq --project_id $PROJECT show dsongcp || bq mk --sync dsongcp

for MONTH in `seq -w 1 12`; do
    CSVFILE=gs://${BUCKET}/flights/raw/${YEAR}${MONTH}.csv
    bq --project_id $PROJECT --sync \
       load --time_partitioning_field=FlightDate --time_partitioning_type=MONTH \
       --source_format=CSV --ignore_unknown_values --skip_leading_rows=1 --schema=$SCHEMA \
       --replace ${PROJECT}:dsongcp.flights_raw\$${YEAR}${MONTH} $CSVFILE
done
```

### 🔍 Ce que fait ce script :

| Étape              | Description                                               |
| ------------------ | --------------------------------------------------------- |
| 🎯 Paramètres      | Prend le nom du bucket et l'année à charger               |
| 📂 Dataset         | Crée le dataset `dsongcp` s’il n’existe pas               |
| 📁 Fichiers        | Parcourt les 12 mois et génère le chemin des fichiers CSV |
| 🧠 Schéma          | Utilise un schéma explicite avec tous les champs de vol   |
| 📆 Partitionnement | Utilise `FlightDate` pour créer des partitions mensuelles |
| ♻️ Remplacement    | Remplace les partitions si elles existent déjà            |

---

💡 Une fois ce script exécuté, vous aurez une table **`dsongcp.flights_raw`** partitionnée mensuellement, prête pour des requêtes optimisées dans BigQuery !

Pour exécuter correctement le script `bqload.sh`, suis ces **3 étapes** :

---

### ✅ 1. Donner les droits d’exécution

Avant de pouvoir lancer le script, rends-le exécutable :

```bash
chmod +x bqload.sh
```

---

### 🚀 2. Lancer le script avec les bons arguments

Le script attend deux arguments :

1. le **nom du bucket GCS** où se trouvent les fichiers CSV (ex. : `my-bucket-name`)
2. l’**année à charger** (ex. : `2015`)

Exemple de commande :

```bash
./bqload.sh my-bucket-name 2015
```

---

### 📂 3. Vérifier dans BigQuery

Une fois le script terminé :

* Une table partitionnée `flights_raw` est créée dans le dataset `dsongcp`
* Tu peux la visualiser avec :

```bash
bq ls dsongcp
```

Et tu peux tester une requête simple sur une partition spécifique :

```sql
SELECT * FROM dsongcp.flights_raw
WHERE FlightDate BETWEEN '2015-01-01' AND '2015-01-31'
LIMIT 10;
```

---

## Planification des téléchargements mensuels

### 🧠 Problème de départ

Tu as déjà téléchargé les données historiques de vols (par exemple pour l’année 2015) et tu les as mises dans un bucket Google Cloud Storage (GCS).
Mais ces données sont **actualisées chaque mois** par le site officiel du gouvernement américain (BTS). Tu veux donc une méthode **automatique** pour télécharger chaque mois les nouvelles données de vol.

---

### 🎯 Objectif

Mettre en place un système **automatisé**, **sans serveur** (pas besoin de gérer un ordinateur ou un serveur toi-même) pour que, chaque mois :

1. Un script aille chercher les nouvelles données du site web du gouvernement.
2. Ces données soient téléchargées.
3. Puis envoyées automatiquement dans ton bucket Cloud Storage.

---

### 🛠️ Outils utilisés

| Outil Google Cloud  | Rôle dans le processus                                                                                                               |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| **Cloud Scheduler** | C’est comme un `cron` sur Linux : il permet de lancer une tâche automatiquement selon un calendrier (ex : le 3 de chaque mois à 7h). |
| **Cloud Run**       | Permet d’exécuter ton code dans un conteneur Docker **via une simple URL**, sans gérer de serveur.                                   |
| **Flask (Python)**  | Framework léger qui transforme ton code Python en **service web** (accessible par une URL).                                          |
| **Docker**          | Sert à emballer ton application Python dans un "conteneur" prêt à être exécuté par Cloud Run.                                        |

---

### 📦 Stratégie complète pas à pas

1. **Tu crées un script Python `ingest_flights.py`**
   ➜ Ce script est capable de télécharger les données pour un **mois donné** (ex: janvier 2024), et les envoyer vers Cloud Storage.

2. **Tu encapsules ce script dans une application Flask (`main.py`)**
   ➜ Grâce à Flask, tu peux appeler ton script via une **URL** (ex: `https://.../ingest?year=2024&month=01`).

3. **Tu emballes tout ça dans un conteneur Docker**
   ➜ Le conteneur contient tout ce qu’il faut pour exécuter ton code.

4. **Tu déploies le conteneur sur Cloud Run**
   ➜ Tu obtiens une URL unique pour appeler ton application Flask.

5. **Tu crées une tâche dans Cloud Scheduler**
   ➜ Elle est configurée pour **appeler cette URL tous les mois** (ex : le 5 de chaque mois à 3h du matin).

---

### 💬 En résumé (image mentale simple)

Imagine un **robot invisible** (Cloud Scheduler) qui, tous les mois, va visiter un site web (ton app Flask sur Cloud Run).
Quand il arrive sur la page `https://.../ingest?year=2024&month=07`, ton script Python `ingest_flights.py` se déclenche automatiquement.
Il télécharge les nouvelles données du mois de juillet et les range proprement dans ton bucket Google Cloud Storage.

---

## 🧠 Résumé de tout le fichier `ingest_flights.py`

Le fichier complet `ingest_flights.py` constitue un **mini pipeline ETL** depuis les données publiques du gouvernement américain jusqu’à **BigQuery**, en passant par Google Cloud Storage (GCS).

### 1. 📥 Télécharger les données ZIP depuis le site de la BTS (Bureau of Transportation Statistics)

```python
zipfile = download(year, month, tempdir)
```

📌 La fonction `download()` utilise une URL basée sur la variable `SOURCE` (`SOURCE = "https://transtats.bts.gov/PREZIP"`) pour télécharger le ZIP du mois/année demandé.

---

### 2. 🧾 Extraire et compresser le CSV

```python
bts_csv = zip_to_csv(zipfile, tempdir)
```

📌 Extrait le fichier `.csv` depuis l’archive `.zip` puis le compresse en `.csv.gz`.

---

### 3. ☁️ Uploader sur GCS

```python
gcsloc = upload(bts_csv, bucket, gcsloc)
```

📌 Upload du fichier `.csv.gz` dans un bucket Google Cloud Storage (`gs://...`).

---

### 4. 🧩 Charger dans BigQuery (avec partition mensuelle)

```python
return bqload(gcsloc, year, month)
```

📌 Charge le fichier GCS dans une table BigQuery `dsongcp.flights_raw`, **partitionnée par mois via la colonne `FlightDate`**.

La table cible est du type :

```text
flights_raw$201501
```

> ✅ Il s’agit d’un **chargement partitionné** qui **remplace** les données si elles existent déjà (`WRITE_TRUNCATE`).

---

### 5. 🔁 Fonction `ingest(year, month, bucket)`

**C’est le point d’entrée unique de tout le fichier**.

Elle orchestre :

1. Le téléchargement
2. L’extraction + compression
3. L’upload vers GCS
4. Le chargement dans BigQuery

> Cette fonction est idéale pour être appelée depuis un script ou une API (comme un endpoint Flask ou FastAPI), par exemple :

```python
ingest("2015", "01", "mon-bucket-gcs")
```

---

### 6. 📆 `next_month(bucketname)`

Fonction utile pour automatiser le traitement mensuel.

* Elle va scanner le bucket GCS (`flights/raw/*.csv.gz`) pour voir le dernier fichier.
* Elle extrait le `year` et `month` du dernier fichier trouvé.
* Puis elle appelle `compute_next_month()` pour calculer le mois suivant.

Exemple :

* Si le dernier fichier est `flights/raw/202401.csv.gz`, il retournera `2024,02`.

---

### 7. 🗓️ `compute_next_month(year, month)`

Ajoute 30 jours à une date fixe du mois courant (`15`), ce qui garantit de passer au mois suivant sans edge case sur la longueur du mois.

---

### 8. 🖥️ Mode CLI (Command-Line Interface)

Bloc exécutable depuis un terminal :

```bash
python3 ingest_flights.py --bucket $BUCKET --year 2023 --month 05
```

Ou si on veut laisser le script choisir le **mois suivant automatiquement** :

```bash
python3 ingest_flights.py --bucket $BUCKET
```

Avec logging en mode debug :

```bash
python3 ingest_flights.py --bucket $BUCKET --debug
```

---

## Exécution test du script `ingest_flights.py`

```bash
python3 ingest_flights.py --bucket $BUCKET
```

### Erreur attendue si les identifiants ne sont pas configurés

Si vos identifiants par défaut ne sont pas encore configurés, vous obtiendrez une erreur similaire à :

```bash
 File "/home/vant/Documents/learning/datascience-on-gcp/.venv/lib/python3.12/site-packages/google/auth/_default.py", line 685, in default
    raise exceptions.DefaultCredentialsError(_CLOUD_SDK_MISSING_CREDENTIALS)
google.auth.exceptions.DefaultCredentialsError: Your default credentials were not found. To set up Application Default Credentials, see https://cloud.google.com/docs/authentication/external/set-up-adc for more information.
```

👉 **Explication de l'erreur :**
Cette erreur indique que le script n’a pas trouvé d'identifiants valides pour s’authentifier auprès des services Google Cloud. Il faut donc configurer un compte de service et fournir sa clé au script.

---

### Création d'un compte de service en tant qu'identité de notre script

Un **compte de service** est une identité utilisée par des applications ou des services automatisés pour interagir avec Google Cloud avec des permissions précises et limitées. Voici les étapes pour en créer un et lui attribuer les droits nécessaires :

```bash
SVC_ACCT=svc-monthly-ingest                     # Nom du compte de service
PROJECT=$(gcloud config get-value project)      # Récupération du projet actif
REGION=us-central1                              # Région (à adapter si besoin)
BUCKET=${PROJECT}-dsongcp                       # Nom du bucket
SVC_PRINCIPAL=serviceAccount:${SVC_ACCT}@${PROJECT}.iam.gserviceaccount.com
```

#### Création du compte de service

```bash
gcloud iam service-accounts create $SVC_ACCT --display-name "flights monthly ingest"
```

➡ Crée un compte de service nommé `svc-monthly-ingest` avec une description.

---

#### Activation de l'accès uniforme au bucket

```bash
gsutil uniformbucketlevelaccess set on gs://$BUCKET
```

➡ Active la gestion uniforme des permissions au niveau du bucket (et non des objets).

---

#### Attribution des droits sur le bucket

```bash
gsutil iam ch ${SVC_PRINCIPAL}:roles/storage.admin gs://$BUCKET
```

➡ Donne au compte de service le rôle **Storage Admin** sur le bucket pour gérer les fichiers.

---

#### Attribution des droits BigQuery

```bash
bq --project_id=${PROJECT} query --nouse_legacy_sql \
  "GRANT \`roles/bigquery.dataOwner\` ON SCHEMA dsongcp TO '$SVC_PRINCIPAL'"
```

➡ Donne au compte de service le rôle **dataOwner** sur le dataset BigQuery `dsongcp`.

```bash
gcloud projects add-iam-policy-binding ${PROJECT} \
  --member ${SVC_PRINCIPAL} \
  --role roles/bigquery.jobUser
```

➡ Permet au compte de service de lancer des jobs BigQuery.

---

#### Création de la clé du compte de service

```bash
gcloud iam service-accounts keys create key.json \
  --iam-account=${SVC_ACCT}@${PROJECT}.iam.gserviceaccount.com
```

➡ Génére un fichier `key.json` contenant la clé privée du compte de service. Ce fichier sera utilisé par votre script pour s’authentifier.

---

#### Définition des identifiants applicatifs

```bash
export GOOGLE_APPLICATION_CREDENTIALS=key.json
```

➡ Indique au SDK Google Cloud et aux bibliothèques clientes d’utiliser cette clé pour s’authentifier.

---

### Exécution du pipeline

Après avoir configuré les identifiants et les permissions, nous avons lancé plusieurs exécutions du script pour ingérer les données des vols mois par mois. Voici un exemple des commandes et des résultats observés :

```bash
python3 ingest_flights.py --bucket $BUCKET
INFO: Requesting data for 2016-01-*
INFO: Extracted /tmp/ingest_flightsrvokv_6v/On_Time_Reporting_Carrier_On_Time_Performance_(1987_present)_2016_1.csv
INFO: Compressed into /tmp/ingest_flightsrvokv_6v/On_Time_Reporting_Carrier_On_Time_Performance_(1987_present)_2016_1.csv.gz
INFO: <Bucket: ds-on-gcp-464823-dsongcp>
INFO: Uploaded gs://ds-on-gcp-464823-dsongcp/flights/raw/201601.csv.gz ...
INFO: Success ... ingested 445827 rows to ds-on-gcp-464823.dsongcp.flights_raw$201601
```

➡ Le script télécharge les données de janvier 2016, les compresse, les charge sur le bucket GCS, puis les importe dans BigQuery (445 827 lignes).

---

```bash
python3 ingest_flights.py --bucket $BUCKET
INFO: Requesting data for 2016-02-*
...
INFO: Success ... ingested 423889 rows to ds-on-gcp-464823.dsongcp.flights_raw$201602
```

➡ Février 2016 : 423 889 lignes ingérées.

---

```bash
python3 ingest_flights.py --bucket $BUCKET
INFO: Requesting data for 2016-03-*
...
INFO: Success ... ingested 451236 rows to ds-on-gcp-464823.dsongcp.flights_raw$201603
```

➡ Mars 2016 : 451 236 lignes ingérées.

---

```bash
python3 ingest_flights.py --bucket $BUCKET
INFO: Requesting data for 2016-04-*
...
INFO: Success ... ingested 461630 rows to ds-on-gcp-464823.dsongcp.flights_raw$201604
```

➡ Avril 2016 : 461 630 lignes ingérées.

---

### Vérification des données dans BigQuery

Pour vérifier que les données ont bien été importées dans BigQuery, vous pouvez exécuter une requête comme celle-ci dans la console BigQuery ou en ligne de commande :

```sql
SELECT * 
FROM dsongcp.flights_raw
WHERE FlightDate BETWEEN '2016-04-01' AND '2016-04-30';
```

✅ **Résultat attendu :**
La requête retourne bien **461 630 lignes**, correspondant aux données du mois d’avril 2016.

---

Si tu veux, je peux aussi ajouter un paragraphe pour expliquer comment automatiser ce pipeline (par exemple via Cloud Scheduler ou un DAG Airflow), ou proposer un schéma de l’architecture ! Dis-le-moi !



