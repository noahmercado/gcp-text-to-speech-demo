#!/usr/bin/env python3

import os
from io import BytesIO
from google.cloud import texttospeech
from flask import Flask, request, send_file
from flask_cors import CORS

# Use app for GCP
app = Flask(__name__)
app.config['SECRET_KEY'] = 'caugusto-weweax'

CORS(app)

client = texttospeech.TextToSpeechClient()

@app.route('/api/voices', methods=['GET'])
def get_voices():
    """
    Route to display home page and form to receive text from user for speech synthesis.
    """
    # print(path)
    # Get the language list
    voices = client.list_voices()

    # Return JSON obj of voice name => gender
    return {voice.name : voice.ssml_gender.name for voice in voices.voices}

@app.route('/api/synthesize', methods=['POST'])
def synthesize():
    """
    Route to synthesize speech using Google Text-to-Speech API.
    """

    print(request)
    # Get the request JSON payload
    payload = request.get_json(silent=True)

    # Set the text input to be synthesized
    synthesis_input = texttospeech.SynthesisInput(text=payload['text'])

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
    response = client.synthesize_speech(input=synthesis_input, voice=voice, audio_config=audio_config)

    # The response's audio_content is binary so we load it into a file-like 
    # object to send it back to the client
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
            "extension": "ulaw"
        },
        "ALAW": {
            "mimetype": "audio/x-alaw-basic",
            "extension": "alaw"
        }
    }

    filename = f'output.{encodings[payload["audioEncoding"]]["extension"]}'
    mimetype = encodings[payload["audioEncoding"]]["mimetype"]

    return send_file(audio_file, mimetype=mimetype, as_attachment=True, attachment_filename=filename)

if __name__ == "__main__":
    app.run(debug=True, host='0.0.0.0', port=int(os.environ.get('PORT', 8080)))
