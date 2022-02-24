#!/usr/bin/env /bin/bash
API_KEY="<YOUR API KEY>"
URL="https://<ENDPOINT>/endpoint/data/beta"
CLUSTER="<Name of your Cluster>"

STR01="\nOk, I picked a word, try to guess\n"
STR02="What is your guess:"
STR03="You won!"
STR04="\nYou failed. The word was"

WORDS=$(curl --location --fail --request POST -s $URL'/action/aggregate' \
  --header 'Content-Type: application/json' \
  --header 'Access-Control-Request-Headers: *' \
  --header 'api-key: '$API_KEY \
  --data-raw '{
    "collection":"words",
    "database":"wordle",
    "dataSource":"'$CLUSTER'",
    "pipeline": [{"$sample": {"size": 1}}')

if [[ $? -eq 0 ]]; then
  # Success loading Mongo
  WORD=$(echo WORDS | jq -r .documents[0].word)
else
  # Failed, random word from local
  if [[ "x$1" == "x" ]]; then
    LANG="-us"
  else
    LANG="-br"
    STR01="\nOk, escolhi uma palavra de 5 letras, consegue advinhar?\n"
    STR02="Qual palavra eu escolhi?"
    STR03="\nParabéns, você descobriu!\n"
    STR04="\nVocê falhou. A palavra era"
  fi
  JSON="words$LANG.json"
  WORDS=$(grep -o -i word $JSON | wc -l)
  PICK=$(shuf -i 0-$WORDS -n 1)
  WORD=$(jq -r .[$PICK].word $JSON)
fi

echo -e "$STR01"
GO_ON=1
TRIES=0
while [[ $GO_ON -eq 1 ]]; do
  TRIES=$(expr $TRIES + 1)
  read -n 5 -p "$STR02 " USER_GUESS
  USER_GUESS=$(echo "$USER_GUESS" | awk '{print toupper($0)}')
  STATE=""
  for i in {0..4}; do
    if [[ "${WORD:i:1}" == "${USER_GUESS:i:1}" ]]; then
      STATE=$STATE"🟩"
    elif [[ $WORD =~ "${USER_GUESS:i:1}" ]]; then
      STATE=$STATE"🟨"
    else
      STATE=$STATE"⬛️"
    fi
  done
  echo "  "$STATE
  if [[ $USER_GUESS == $WORD ]]; then
    echo -e "$STR03"
    GO_ON=0
  elif [[ $TRIES == 5 ]]; then
    echo -e "$STR04 $WORD.\n"
    GO_ON=0
  fi
done
