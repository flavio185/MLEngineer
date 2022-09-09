from azure_experiment import AzureModel 

import sys


#Main
def saveModel(model_name):
    model_name = model_name[-1]
    m1 = AzureModel()
    m1.startExperimentRun(model_name)
    m1.logMetadataJson()
    m1.finishExperimentRun()
    m1.registerModelArtifacts()

if __name__ == "__main__":
    myfunc(sys.argv)
