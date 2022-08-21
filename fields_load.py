import json

def getFielsds():
    f = open("fields.json")
    my_json = json.loads(f.read())
    for key in my_json['input']:
        print(key, my_json['input'][key])

getFielsds()