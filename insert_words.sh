API_KEY="<YOUR API KEY>"
URL="https://<ENDPOINT>/endpoint/data/beta"
CLUSTER="<Name of your Cluster>"

curl --location --request POST  $URL'/action/insertMany' \
--header 'Content-Type: application/json' \
--header 'Access-Control-Request-Headers: *' \
--header 'api-key: '$API_KEY \
--data-raw '{
    "collection":"words2",
    "database":"wordle",
    "dataSource":"'$CLUSTER'",
    "documents": '$(curl -s https://raw.githubusercontent.com/mongodb-developer/bash-wordle/main/words.json)'
}'