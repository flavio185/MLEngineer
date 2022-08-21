import predict 
from flask import Flask, jsonify, request

app = Flask(__name__)

@app.route("/")
def hello():
    return "Running"

@app.route('/api',methods=['POST'])
def run_predict():
    data = request.get_json(force=True)
    experience_level = str(data['experience_level'])
    employment_type = str(data['employment_type'])
    company_size = str(data['company_size'])
    work_year= str(data['work_year'])
    job_title = str(data['job_title'])
    remote_ratio = str(data['remote_ratio'])
    employee_residence = str(data['employee_residence'])

    output = predict.predict(experience_level, employment_type, company_size, work_year, job_title, remote_ratio, employee_residence)

    return jsonify(output[0])


if(__name__=='__main__'):
    app.run(host='0.0.0.0', debug=True, port=80)