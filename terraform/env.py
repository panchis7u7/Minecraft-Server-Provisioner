import json

parsed_json={}
file = open("../.env/xcp_credentials.env")
for line in file:
    splitted_line = line.split("=")
    parsed_json[splitted_line[0]] = splitted_line[1].replace("\n", "")
output_json = json.dumps(parsed_json, indent=2)
print(output_json)