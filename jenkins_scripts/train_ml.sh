#!/bin/bash

git clone
cd $cloned_git
docker build $cloned_git/requirement.xml
docker run -d python_training:latest python -d $cloned_git/Train:/code/$cloned_git



#clonar repo
#buildar o docker colocando classe azure ml la dentro
#buildar docker baseado no requirement.txt do train.
#nome do docker é o ${cloned_git_dir}:latest.
#mandar diretório para dentro do docker. /app/train/${cloned_git_dir}
#startar docker executando o script de train e save model.
