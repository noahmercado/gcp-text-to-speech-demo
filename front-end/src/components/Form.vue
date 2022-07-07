<template>
  <v-card>
    <v-container>
      <v-row>
        <v-col>
          <v-form ref="form" v-model="valid" lazy-validation>
            <v-row>
              <v-col cols="12">
                <v-textarea v-model="text" color="teal" prepend-icon="mdi-tooltip-text-outline"
                  :rules="[v => !!v || 'Input text is required']">
                  <template v-slot:label>
                    <div>
                      Text to Synthesize
                    </div>
                  </template>
                </v-textarea>
              </v-col>
            </v-row>
            <v-row dense>
              <v-col class="d-flex" cols="12">
                <v-spacer></v-spacer>
                <v-switch v-model="ssml" label="SSML" color="orange"></v-switch>
              </v-col>
            </v-row>

            <v-row>
              <v-col>
                <small>Voice Configuration</small>
              </v-col>
            </v-row>
            <v-row>
              <v-col cols="2">
                <v-select v-model="language" :items="languageCodes" :rules="[v => !!v || 'Language is required']"
                  label="Language" required prepend-icon="mdi-translate">
                </v-select>
              </v-col>
              <v-spacer></v-spacer>
              <v-col cols="2">
                <v-select v-model="dialect" :items="dialects" :rules="[v => !!v || 'Dialect is required']"
                  label="Dialect" required prepend-icon="mdi-map-marker-plus-outline">
                </v-select>
              </v-col>
              <v-spacer></v-spacer>
              <v-col cols="2">
                <v-select v-model="gender" :items="genders" :rules="[v => !!v || 'Gemder is required']" label="Gender"
                  required prepend-icon="mdi-gender-male-female">
                </v-select>
              </v-col>
              <v-spacer></v-spacer>
              <v-col cols="2">
                <v-select v-model="voiceType" :items="voiceTypes" :rules="[v => !!v || 'Voice Type is required']"
                  label="Voice Type" required prepend-icon="mdi-waveform">
                </v-select>
              </v-col>
              <v-spacer></v-spacer>
              <v-col cols="2">
                <v-select v-model="voice" :items="voices" :rules="[v => !!v || 'Voice is required']" label="Voice"
                  required prepend-icon="mdi-account-voice">
                </v-select>
              </v-col>
              <v-spacer></v-spacer>
            </v-row>

            <v-row>
              <v-col>
                <small>Audio Configuration</small>
              </v-col>
            </v-row>

            <v-row>
              <v-spacer></v-spacer>
              <v-col cols="3">
                <v-select v-model="encoding" :items="encodings" :rules="[v => !!v || 'Audio Encoding is required']"
                  label="Audio Encoding" required prepend-icon="mdi-audio-input-rca" dense>
                </v-select>
              </v-col>

              <v-spacer></v-spacer>
              <v-col cols="3">
                <v-slider v-model="speed" thumb-label="always" label="Playback Speed" max="4.0" min="0.25" step="0.25"
                  prepend-icon="mdi-play-speed"></v-slider>
              </v-col>

              <v-spacer></v-spacer>
              <v-col cols="3">
                <v-slider v-model="pitch" thumb-label="always" label="Pitch" max="20" min="-20" step="0.50"
                  prepend-icon="mdi-android"></v-slider>
              </v-col>

              <v-spacer></v-spacer>
            </v-row>

            <v-row>
              <v-spacer></v-spacer>
              <v-col cols="4">
                <v-select v-model="effects" :items="effectsOptions" multiple label="Audio Effects Profiles"
                  prepend-icon="mdi-cast-audio">
                  <template #selection="{ item }">
                    <v-chip color="primary" close draggable @click:close="deleteEffect(item)">{{item}}</v-chip>
                  </template>
                </v-select>
              </v-col>
              <v-spacer></v-spacer>

              <v-col cols="4">
                <v-text-field v-model="sampleHertzRate" label="Sample Hertz Rate" type="number" clearable
                  :rules="sampleHertzValidationRules"  prepend-icon="mdi-sine-wave"
                ></v-text-field>
              </v-col>
              <v-spacer></v-spacer>
            </v-row>

            <v-checkbox v-model="storeSynthesis" label="Store synthesis in history" required>
            </v-checkbox>

            <v-btn :disabled="!valid" color="success" class="mr-4" @click="synthesize">
              Synthesize
            </v-btn>

            <v-btn color="error" class="mr-4" @click="reset">
              Reset
            </v-btn>
          </v-form>
        </v-col>
      </v-row>
      <v-row v-if="media != null" justify="center" align="center" dense>
        <v-col>
          <v-btn color="blue" class="mr-4" @click="download">
            <v-icon color="white">mdi-download-circle-outline</v-icon>
          </v-btn>
          <audio controls v-if="playableAudio">
            <source :src="this.media.url" :type="this.media.mimetype">
            Your browser does not support the audio element.
          </audio>
        </v-col>
      </v-row>
    </v-container>
  </v-card>
</template>

<script>
  export default {
    name: "SynthesizeForm",

    props: {
      languages: {
        default: function () {
          return null
        },
      },
      user: {
        default: function () {
          return null
        }
      },
    },
    data: () => ({
      speed: 1.0,
      pitch: 0.0,
      text: null,
      media: null,
      valid: true,
      ssml: false,
      language: null,
      dialect: null,
      gender: null,
      voiceType: null,
      encoding: null,
      voice: null,
      sampleHertzValidationRules: [
        v => (8000 <= v || v == null) || 'Sample Hertz must be empty or >= 8000',
        v => (v <= 22579200 || v == null) || 'Sample Hertz must be empty or <= 22579200'
      ],
      sampleHertzRate: null,
      colors: [
        "primary",
        "success",
        "error",
        "orange"
      ],
      effects: [],
      effectsOptions: [
        "wearable-class-device",
        "handset-class-device",
        "headphone-class-device",
        "small-bluetooth-speaker-class-device",
        "medium-bluetooth-speaker-class-device",
        "large-home-entertainment-class-device",
        "large-automotive-class-device",
        "telephony-class-application"
      ],
      encodings: [
        "LINEAR16",
        "MP3",
        "OGG_OPUS",
        "MULAW",
        "ALAW"
      ],
      storeSynthesis: false,
    }),

    computed: {
      languageCodes() {
        return Object.keys(this.languages).map((name) => {
          return name.split("-")[0]
        })
      },
      playableAudio() {
        return this.media.mimetype == "audio/mpeg" || this.media.mimetype == "audio/ogg"
      },
      dialects() {
        return [...new Set(Object.keys(this.languages).map((name) => {
          let [lang, dial] = name.split("-")
          return [lang, dial].join("-")
        }).filter((dial) => {
          return dial.startsWith(this.language)
        }))]
      },
      genders() {
        return [...new Set(Object.entries(this.languages).filter(([key]) => {
          return key.startsWith(this.dialect)
        }).map(([, value]) => {
          return value
        }))]
      },
      voiceTypes() {
        return [...new Set(Object.keys(this.languages).filter((type) => {
            return type.startsWith(this.dialect)
          })
          .map((name) => {
            return name.split("-")[2]
          }))]
      },
      voices() {
        return [...new Set(Object.entries(this.languages).filter(([key, value]) => {
            return key.startsWith(`${this.dialect}-${this.voiceType}`) && value == this.gender
          })
          .map(([name]) => {
            return name.split("-")[3]
          }))]
      },
    },

    methods: {
      randomColor() {
        let randomIdx = Math.floor(Math.random() * ((this.colors.length - 1) - 0) + 0)
        let color = this.colors[randomIdx]
        console.log(randomIdx)
        console.log(color)
        return color
      },
      async synthesize() {
        this.$refs.form.validate()
        this.media = null

        if (!this.valid) {
          console.log("Invalid form inputs!")
          return
        }

        this.$emit("loading", true)
        let token = await this.user.getIdToken()
        const requestOptions = {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "Authorization": `Bearer ${token}`
          },
          body: JSON.stringify({
            text: this.text,
            gender: this.gender,
            pitch: this.pitch,
            speakingRate: this.speed,
            voiceName: `${this.dialect}-${this.voiceType}-${this.voice}`,
            audioEncoding: this.encoding,
            storeSynthesis: this.storeSynthesis,
            userId: this.user.uid,
            ssml: this.ssml,
            effectsProfileId: this.effects,
            sampleHertzRate: this.sampleHertzRate,
          })
        }

        let response = await fetch("/api/synthesize", requestOptions)
        console.log(response)

        if (response.status != 200){
          console.log("Error synthesizing input!")
          return
        }

        let blob = await response.blob()
        console.log(blob)

        this.media = {
          url: URL.createObjectURL(blob),
          mimetype: response.headers.get('content-type'),
          filename: response.headers.get('content-disposition').split("filename=")[1],
        }

        this.$emit("loading", false)
      },
      deleteEffect(item) {
        this.effects = this.effects.filter((effect) => {
          return effect != item
        })
      },
      reset() {
        this.$refs.form.reset()
        this.speed = 1.0
        this.media = null
      },
      resetValidation() {
        this.$refs.form.resetValidation()
      },
      download() {
        var a = document.createElement('a')
        a.href = this.media.url
        a.download = this.media.filename
        document.body.appendChild(
          a) // we need to append the element to the dom -> otherwise it will not work in firefox
        a.click()
        a.remove()
      }
    },
    watch: {
      dialects: function (n) {
        if (n.length == 1) {
          this.dialect = this.dialects[0]
        }
      },
      genders: function (n) {
        if (n.length == 1) {
          this.gender = this.genders[0]
        }
      },
      voiceTypes: function (n) {
        if (n.length == 1) {
          this.voiceType = this.voiceTypes[0]
        }
      },
      voices: function (n) {
        if (n.length == 1) {
          this.voice = this.voices[0]
        }
      },
    }
  }
</script>