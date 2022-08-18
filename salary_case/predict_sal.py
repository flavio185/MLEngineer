def predict_salary(experience_level, employment_type, company_size, work_year, job_title, remote_ratio, employee_residence):

    work_year = str(work_year)
    categorical = enc.transform([[work_year, job_title, remote_ratio, employee_residence]]).toarray()
    categorical = categorical.reshape(categorical.shape[1],)

    experience_level_map = {"Entry":1, "Junior":2, "Senior":3, "Expert":4}
    employment_type_map = {"Freelance":1, "Contract":2, "Part-time":3, "Full-time":4}
    company_size_map = {"Small":1, "Medium":2, "Large":3}

    experience_level = experience_level_map[experience_level]
    employment_type = employment_type_map[employment_type]
    company_size = company_size_map[company_size]

    label_encoded = np.array([experience_level, employment_type, company_size])
    processed_data = np.concatenate((categorical,label_encoded))
    processed_data = processed_data.reshape(1, processed_data.shape[0])

    salary_prediction = model.predict(processed_data)
    
    return(salary_prediction)

sal = predict_salary("Junior", "Full-time", "Large", 2020, "Data Scientist", "Onsite", "DE")

print("Salário predito: "+str(sal))
