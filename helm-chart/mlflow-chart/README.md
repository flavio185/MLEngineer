

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
  
When MLflow is configured to use PostgreSQL as the backend store, it automatically creates several tables to store metadata about experiments, runs, metrics, parameters, tags, and artifacts. Here are the main tables that MLflow creates in the PostgreSQL database:

### Tables Created by MLflow

1. **experiments**:
   - Stores information about experiments.
   - Columns:
     - `experiment_id`: Unique identifier for the experiment.
     - `name`: Name of the experiment.
     - `artifact_location`: Location where artifacts are stored.
     - `lifecycle_stage`: Lifecycle stage of the experiment (e.g., active, deleted).
     - `creation_time`: Timestamp when the experiment was created.
     - `last_update_time`: Timestamp when the experiment was last updated.

2. **runs**:
   - Stores information about runs.
   - Columns:
     - `run_uuid`: Unique identifier for the run.
     - `name`: Name of the run.
     - `source_type`: Type of the source (e.g., notebook, project).
     - `source_name`: Name of the source.
     - `entry_point_name`: Entry point name.
     - `user_id`: User who initiated the run.
     - `status`: Status of the run (e.g., running, finished, failed).
     - `start_time`: Timestamp when the run started.
     - `end_time`: Timestamp when the run ended.
     - `source_version`: Version of the source.
     - `lifecycle_stage`: Lifecycle stage of the run (e.g., active, deleted).
     - `artifact_uri`: URI where artifacts are stored.
     - `experiment_id`: Identifier of the experiment to which the run belongs.

3. **metrics**:
   - Stores metrics logged during runs.
   - Columns:
     - `key`: Name of the metric.
     - `value`: Value of the metric.
     - `timestamp`: Timestamp when the metric was logged.
     - `run_uuid`: Identifier of the run to which the metric belongs.
     - `step`: Step at which the metric was logged.

4. **params**:
   - Stores parameters logged during runs.
   - Columns:
     - `key`: Name of the parameter.
     - `value`: Value of the parameter.
     - `run_uuid`: Identifier of the run to which the parameter belongs.

5. **tags**:
   - Stores tags associated with runs.
   - Columns:
     - `key`: Name of the tag.
     - `value`: Value of the tag.
     - `run_uuid`: Identifier of the run to which the tag belongs.

6. **latest_metrics**:
   - Stores the latest values of metrics for each run.
   - Columns:
     - `key`: Name of the metric.
     - `value`: Latest value of the metric.
     - `timestamp`: Timestamp when the metric was last logged.
     - `run_uuid`: Identifier of the run to which the metric belongs.
     - `step`: Step at which the metric was last logged.

### Example SQL Queries to Inspect Tables

You can use the following SQL queries to inspect the tables created by MLflow in PostgreSQL:

1. **List all tables**:
   ```sql
   SELECT table_name
   FROM information_schema.tables
   WHERE table_schema = 'public';
   ```

2. **Describe the `experiments` table**:
   ```sql
   \d experiments
   ```

3. **Describe the `runs` table**:
   ```sql
   \d runs
   ```

4. **Describe the `metrics` table**:
   ```sql
   \d metrics
   ```

5. **Describe the `params` table**:
   ```sql
   \d params
   ```

6. **Describe the `tags` table**:
   ```sql
   \d tags
   ```

7. **Describe the `latest_metrics` table**:
   ```sql
   \d latest_metrics
   ```

### Summary

MLflow creates several tables in the PostgreSQL database to store metadata about experiments, runs, metrics, parameters, tags, and artifacts. These tables include `experiments`, `runs`, `metrics`, `params`, `tags`, and `latest_metrics`. You can use SQL queries to inspect these tables and understand the structure and data stored in them.

### Minio

jem