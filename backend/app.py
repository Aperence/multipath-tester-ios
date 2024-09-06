from flask import Flask, request
import json

app = Flask(__name__)

@app.route("/measure-data", methods=["POST"])
def hello_world():
    data = request.get_data()
    data = json.loads(data)
    print(F"Received data :\n{json.dumps(data, indent=2)}")
    # do what we want with data, note that the date is a unix timestamp, and measures
    # are in ms
    return {"status": "ok"}