from azure_experiment import AzureModel 

import sys


#Main
def downloadModel(args):
    ver=None
    for i in args:
        if 'version' in i:
            ver=i.split('=')[1]
        if 'model_name' in i:
            m_name=i.split('=')[1]

    m1 = AzureModel()
    m1.downloadModelArtifacts(m_name, version=ver)

if __name__ == "__main__":
    downloadModel(sys.argv)
