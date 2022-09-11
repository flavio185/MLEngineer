from azure_experiment import AzureModel 

import sys


#Main
def downloadModel(model_name):
    model_name = model_name[-1]
    m1 = AzureModel()
    #m1.downloadModelArtifacts(model_name, target_dir="app", version=3)
    m1.downloadModelArtifacts(model_name, target_dir="app")

if __name__ == "__main__":
    downloadModel(sys.argv)
