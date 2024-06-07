import base64
import os
import json
from google.cloud import bigquery
from google.cloud import storage

def hello_pubsub(event, context):
    """Triggered from a message on a Cloud Pub/Sub topic.
    Args:
         event (dict): Event payload.
         context (google.cloud.functions.Context): Metadata for the event.
    """
    # Extract the Pub/Sub message
    pubsub_message = base64.b64decode(event['data']).decode('utf-8')
    print(pubsub_message)

    # Parse the message to get the bucket name and file name
    message_json = json.loads(pubsub_message)
    bucket_name = message_json['bucket']
    file_name = message_json['name']

    # Fetch BigQuery variables from environment variables
    project_id = os.getenv('project_id')
    dataset_id = os.getenv('database_name')
    table_id = os.getenv('table_name')

    # Initialize BigQuery client
    bq_client = bigquery.Client(project=project_id)

    # Initialize Storage client
    storage_client = storage.Client()

    # Get bucket and file objects
    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(file_name)

    # Download CSV file to temporary location
    temp_local_file = '/tmp/temp.csv'
    blob.download_to_filename(temp_local_file)

    # Load CSV data into BigQuery table
    table_ref = bq_client.dataset(dataset_id).table(table_id)
    job_config = bigquery.LoadJobConfig(
        autodetect=True,
        skip_leading_rows=1,
        source_format=bigquery.SourceFormat.CSV
    )

    with open(temp_local_file, 'rb') as source_file:
        job = bq_client.load_table_from_file(
            source_file,
            table_ref,
            location='US',  # Change this to your dataset's location
            job_config=job_config
        )

    job.result()

    print(f'CSV file {file_name} loaded into BigQuery table {table_id}')

    # Clean up temporary file
    os.remove(temp_local_file)
