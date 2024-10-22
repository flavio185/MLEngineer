

MLFLOW: Uma plataforma de gerenciamento de ciclo de vida de machine learning que ajuda a experimentar, gerenciar e compartilhar modelos de machine learning. Pode ser usada para rastrear experimentos e gerenciar modelos.

Helm: Um gerenciador de pacotes para Kubernetes, que facilita a instalação e gerenciamento de aplicativos em clusters Kubernetes.

Kubernetes: Uma plataforma de orquestração de contêineres que permite implantar, gerenciar e dimensionar aplicativos em contêineres. É amplamente usada para gerenciar ambientes de produção de machine learning.

PostgreSQL: Um sistema de gerenciamento de banco de dados relacional que pode ser usado para armazenar dados experimentais e resultados de machine learning.

Minio: Um armazenamento de objetos compatível com S3 que pode ser usado para armazenar artefatos de machine learning, como modelos treinados e dados.

Esses componentes podem ser integrados para criar um ambiente robusto para desenvolvimento e implantação de modelos de machine learning. Por exemplo, você pode usar MLFLOW para gerenciar seus experimentos, armazenar dados em PostgreSQL e armazenar artefatos em Minio, enquanto usa Kubernetes e Helm para gerenciar a implantação dos seus modelos.


## MLFLOW

Com MLflow, você pode acessar uma variedade de endpoints através da API REST para gerenciar experimentos, runs, parâmetros, métricas e artefatos1
. Aqui estão alguns endpoints comuns:

Experimentos:

Criar Experimento: POST /api/2.0/mlflow/experiments/create
Buscar Experimentos: POST /api/2.0/mlflow/experiments/search
Obter Experimento: GET /api/2.0/mlflow/experiments/get
Deletar Experimento: DELETE /api/2.0/mlflow/experiments/delete
Atualizar Experimento: PATCH /api/2.0/mlflow/experiments/update

Runs:

Criar Run: POST /api/2.0/mlflow/runs/create
Buscar Runs: POST /api/2.0/mlflow/runs/search
Obter Run: GET /api/2.0/mlflow/runs/get
Deletar Run: DELETE /api/2.0/mlflow/runs/delete
Atualizar Run: PATCH /api/2.0/mlflow/runs/update

Parâmetros e Métricas:

Logar Parâmetro: POST /api/2.0/mlflow/runs/log-params
Logar Métrica: POST /api/2.0/mlflow/runs/log-metric
Buscar Histórico de Métricas: GET /api/2.0/mlflow/runs/get-metric-history

Artefatos:

Listar Artefatos: GET /api/2.0/mlflow/artifacts/list
Obter Artefato: GET /api/2.0/mlflow/artifacts/get
Deletar Artefato: DELETE /api/2.0/mlflow/artifacts/delete

Esses endpoints permitem que você gerencie e interaja com seus experimentos e runs de machine learning de forma programática. Se precisar de mais detalhes ou exemplos de como usar esses endpoints, estou aqui para ajudar!

### Helm

### Kubernetes
 
### #POSTGRES

https://dev.to/dm8ry/how-to-deploy-postgresql-db-server-and-pgadmin-in-kubernetes-a-how-to-guide-5fm0

psql -U $POSTGRES_USER -d $POSTGRES_DB -p $POSTGRES_PASSWORD
 name: POSTGRES_DB
              value: {{ .Values.postgresql.database }}
            - name: POSTGRES_USER
              value: {{ .Values.postgresql.username }}
            - name: POSTGRES_PASSWORD

### Minio

jem