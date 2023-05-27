@echo off
SET corpusName=dblp
SET taxonName=our-l3-0.15
SET FIRST_RUN=1

IF %FIRST_RUN%==1  (
  echo "Start data preprocessing"
  gcc "word2vec-new.c" "-o" "word2vec" "-lm" "-pthread" "-O2" "-Wall" "-funroll-loops" "-Wno-unused-result"
  
  IF not exist "..\data\%corpusName%\init" (
    mkdir "..\data\%corpusName%\init"
  )

  python "-V"
  echo "Activating the poetry env -- %time%"
  "C:\Users\EdCosta\AppData\Local\pypoetry\Cache\virtualenvs\taxogen-hi1r0lfI-py3.10\Scripts\activate.ps1"
  python "-V"

  echo "Start cluster-preprocess.py -- %time%"
  python "cluster-preprocess.py" "%corpusName%"

  echo "Start preprocess.py -- %time%"
  python "preprocess.py" "%corpusName%"

  COPY  "..\data\%corpusName%\input\embeddings.txt" "..\data\%corpusName%\init\embeddings.txt"
  COPY  "..\data\%corpusName%\input\keywords.txt" "..\data\%corpusName%\init\seed_keywords.txt"
)
IF not exist "..\data\%corpusName%\%taxonName%\" (
  mkdir "..\data\%corpusName%\%taxonName%"
)
echo "Start TaxonGen"
python "main.py"
echo "Generate compressed taxonomy"
IF not exist "..\data\%corpusName%\taxonomies\" (
  mkdir "..\data\%corpusName%\taxonomies"
)
python "compress.py" "-root" "..\data\%corpusName%\%taxonName%" "-output" "..\data\%corpusName%\taxonomies\%taxonName%.txt"

deactivate