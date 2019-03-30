develop:
	swipl server.prolog --fork=false --port=8000

post:
	curl --header "Content-Type: application/json" --data @input/test.json http://127.0.0.01:8000/html_struct