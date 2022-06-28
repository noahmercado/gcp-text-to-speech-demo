#!/usr/bin/env python3

import os, json
from io import BytesIO
from google.cloud import texttospeech, storage, firestore
from flask import Flask, request, send_file
from uuid import uuid4
from flask_cors import CORS
import functools
from firebase_admin import initialize_app
from firebase_admin.auth import verify_id_token
from firebase_admin.firestore import SERVER_TIMESTAMP as FIRESTORE_SERVER_TIMESTAMP

# Use app for GCP
app = Flask(__name__)
fb_app = initialize_app()

FIREBASE_DOMAINS = os.environ.get("FIREBASE_DOMAINS", "").split(",")
BROWSER_CACHE_TTL = int(os.environ.get("BROWSER_CACHE_TTL", 300))
CDN_CACHE_TTL = int(os.environ.get("CDN_CACHE_TTL", 3600))

cors = CORS(app, resources={r"/api/*": {"origins": FIREBASE_DOMAINS}})

ttsClient = texttospeech.TextToSpeechClient()
gcsClient = storage.Client()
firestoreClient = firestore.Client()

PORT = int(os.environ.get('PORT', 8080))
GCS_BUCKET_NAME = os.environ.get('GCS_BUCKET_NAME')
BUCKET = gcsClient.get_bucket(GCS_BUCKET_NAME)

def requires_auth(func):
    @functools.wraps(func)
    def decorated_function(*args, **kwargs):
        bearer = request.headers.get("Authorization")
        if not bearer:
            return {"error": "Unauthorized"}, 401
        token = bearer.split()[1]
        try:
            decoded_token = verify_id_token(token)
        except Exception as e:
            print(f"Error verifying token: ")
            print(e)
            return {"error": "Forbidden"}, 403

        print(f"Handling authenticated request from: {json.dumps(decoded_token)}")
        return func(*args, **kwargs)

    return decorated_function

@app.route('/api/voices', methods=['GET'])
@requires_auth
def get_voices():
    """
    Route to display home page and form to receive text from user for speech synthesis.
    """
    print(request)
    # Get the language list
    voices = ttsClient.list_voices()

    headers = {
        "Cache-Control": f"public, max-age={BROWSER_CACHE_TTL}, s-maxage={CDN_CACHE_TTL}"
    }

    # JSON obj of voice name => gender
    json_response = {voice.name : voice.ssml_gender.name for voice in voices.voices}

    # Return json + 200 http code + cache contorl headers
    return json_response, 200, headers

@app.route('/api/synthesize', methods=['POST'])
@requires_auth
def synthesize():
    """
    Route to synthesize speech using Google Text-to-Speech API.
    """

    print(request)
    # Get the request JSON payload
    payload = request.get_json(silent=True)
    print(payload)

    # Set the text input to be synthesized
    synthesis_input = texttospeech.SynthesisInput()

    if payload["ssml"]:
        synthesis_input.ssml = payload["text"]
    else:
        synthesis_input.text = payload['text']

    # Build the voice request, select the language code (i.e. "en-US") and the ssml
    # voice gender (i.e. "MALE")

    # The language_code can be inferred from the voice name. 
    # Naming convention of voice name is [langCode]-[VoiceType]-[VoiceId]
    language_code = "-".join(payload["voiceName"].split("-")[0:2])
    ssml_gender = texttospeech.SsmlVoiceGender[payload["gender"]]
    audio_encoding = texttospeech.AudioEncoding[payload["audioEncoding"]]

    voice = texttospeech.VoiceSelectionParams(
        language_code=language_code,
        name=payload["voiceName"],
        ssml_gender=ssml_gender)

    # Select the type of audio file you want returned
    audio_config = texttospeech.AudioConfig(
        audio_encoding=audio_encoding,
        speaking_rate=payload.get("speakingRate", 1.0),
        pitch=payload.get("pitch", 0.0))

    # Perform the text-to-speech request on the text input with the selected
    # voice parameters and audio file type
    response = ttsClient.synthesize_speech(input=synthesis_input, voice=voice, audio_config=audio_config)

    print(response)
    # The response's audio_content is binary so we load it into a file-like 
    # object to send it back to the ttsClient
    audio_file = BytesIO()
    audio_file.write(response.audio_content)
    audio_file.seek(0)

    encodings = {
        "LINEAR16": {
            "mimetype": "audio/l16",
            "extension": "wav"
        },
        "MP3": {
            "mimetype": "audio/mpeg",
            "extension": "mp3"
        },
        "OGG_OPUS": {
            "mimetype": "audio/ogg",
            "extension": "oga"
        },
        "MULAW": {
            "mimetype": "audio/basic",
            "extension": "wav"
        },
        "ALAW": {
            "mimetype": "audio/x-alaw-basic",
            "extension": "wav"
        }
    }

    filename = f'output.{encodings[payload["audioEncoding"]]["extension"]}'
    mimetype = encodings[payload["audioEncoding"]]["mimetype"]

    try:
        if payload["storeSynthesis"]:
            upload_id = uuid4()
            blob_name = f"{upload_id}/{filename}"
            blob = BUCKET.blob(blob_name)
            blob.upload_from_string(audio_file.getvalue(), content_type=mimetype)

            doc_ref = firestoreClient.collection(u'history').document(f"{upload_id}")
            doc_ref.set({
                **payload,
                "timestamp": FIRESTORE_SERVER_TIMESTAMP,
                "gcsRef": f"gs://{GCS_BUCKET_NAME}/{blob_name}"
            })
    except Exception as e:
        print(e)

    return send_file(audio_file, mimetype=mimetype, as_attachment=True, attachment_filename=filename)

if __name__ == "__main__":
    app.run(debug=True, host='0.0.0.0', port=PORT)
