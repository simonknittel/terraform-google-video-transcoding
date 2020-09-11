import os
import re
import requests

from google.cloud import storage

def index(event, context):
    print(f"File: {event['name']}")

    storage_client = storage.Client()
    input_bucket = storage_client.bucket(os.environ.get("INPUT_BUCKET"))

    local_path = "/tmp/"
    input_file = local_path + event['name']
    local_h264_output_file = local_path + "output-h264.mp4"
    bucket_h264_output_file = re.sub(r"\.[^.]+$", '-h264.mp4', event['name'])

    print("Downloading ...")
    input_blob = input_bucket.blob(event['name'])
    input_blob.download_to_filename(input_file)

    print("Transcoding ...")
    os.system("ffmpeg -i " + input_file + " -c:v libx264 -b:v 500k -maxrate 1M -bufsize 2M -preset veryfast -profile:v high -an -y -map_metadata -1 -movflags +faststart -loglevel warning " + local_h264_output_file)

    print("Uploading ...")
    output_bucket = storage_client.bucket(os.environ.get("OUTPUT_BUCKET"))
    h264_blob = output_bucket.blob(bucket_h264_output_file)
    result = h264_blob.upload_from_filename(local_h264_output_file)
    print(result)

    print("Cleaning up ...")
    os.remove(input_file)
    os.remove(local_h264_output_file)

    print("Sending success mail ...")
    result = requests.post(
        "https://api.eu.mailgun.net/v3/{}/messages".format(os.environ.get("MAILGUN_DOMAIN_NAME")),
        auth=("api", os.environ.get("MAILGUN_API_KEY")),
        data={
            "from": "Video Transcoding <noreply@{}>".format(os.environ.get("MAILGUN_DOMAIN_NAME")),
            "to": [os.environ.get("MAIL_RECEIVER")],
            "subject": "Video Transcoding finished",
            "text": '<b>H.264:</b> <a href="https://storage.googleapis.com/{0}/{1}">https://storage.googleapis.com/{0}/{1}</a><br />'.format(os.environ.get('OUTPUT_BUCKET'), bucket_h264_output_file)
        }
    )
