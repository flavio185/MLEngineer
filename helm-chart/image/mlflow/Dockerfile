# Use the official MLflow image as the base image
FROM ghcr.io/mlflow/mlflow:latest

# Install psycopg2
RUN pip install mlflow psycopg2-binary boto3

# Set the entrypoint to mlflow
ENTRYPOINT ["mlflow"]