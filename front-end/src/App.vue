<template>
  <v-app>
    <AppBar :drawer="drawer" @onDrawerClick="onDrawerClick" :user="user" />
    <NavDrawer :drawer="drawer" @onDrawerClick="onDrawerClick" />

    <v-main>
      <v-container>
        <v-row>
          <v-col >
            <SynthesizeForm :languages="ttsLanguages"/>
          </v-col>
        </v-row>

        <v-row>
          <v-col>
            <v-img src="./assets/TTS-Web-App.drawio.png" alt="Google Text to Speech with Google Cloud Run">
            </v-img>
          </v-col>
        </v-row>
      </v-container>
    </v-main>
  </v-app>
</template>

<script>
  import SynthesizeForm from './components/Form';
  import AppBar from './components/AppBar'
  import NavDrawer from './components/NavDrawer'

  export default {
    name: 'App',

    components: {
      SynthesizeForm,
      AppBar,
      NavDrawer,
    },

    data: () => ({
      drawer: false,
      kit: null,
      parts: [],
      user: null,
      currentTab: "Synthesize",
      kits: {},
      ttsLanguages: {},
    }),

    methods: {
      onDrawerClick(v) {
        this.drawer = v
      },
    },

    created() {
      fetch("/api/voices")
        .then((res) => res.json())
        .then((data) => {
          console.log(data)
          this.ttsLanguages = data
        })
    }
  };
</script>