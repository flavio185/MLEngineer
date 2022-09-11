from azure_experiment import AzureModel 

import sys


#Main
def downloadModel(args):
    m_name = [ i.split('=')[1] for i in args if 'model_name' in i]
    #t_dir = [ i.split('=')[1] for i in args if 'target_dir' in i]
    ver = [ i.split('=')[1] for i in args if 'version' in i]

    m1 = AzureModel()
    #m1.downloadModelArtifacts(m_name, target_dir=t_dir, version=ver)
    m1.downloadModelArtifacts(m_name)

if __name__ == "__main__":
    downloadModel(sys.argv)
