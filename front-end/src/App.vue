<template>
  <v-app>
    <AppBar :drawer="drawer" @onDrawerClick="onDrawerClick" :user="user" @tabSelected="onTabSelect" />
    <NavDrawer :drawer="drawer" @onDrawerClick="onDrawerClick" />

    <v-main>
      <v-container v-show="currentTab=='Synthesize'">
        <v-row>
          <v-col>
            <SynthesizeForm :languages="ttsLanguages" :user="user" @loading="onFormLoading"/>
          </v-col>
        </v-row>

        <v-row>
          <v-col>
            <v-img src="./assets/TTS-Web-App.drawio.png" alt="Google Text to Speech with Google Cloud Run">
            </v-img>
          </v-col>
        </v-row>
      </v-container>
      <v-container v-show="currentTab=='History'">
        <v-row v-if="user.uid">
          <v-col>
            <History :user="user" />
          </v-col>
        </v-row>

        <v-row>
          <v-col>
            <v-img src="./assets/TTS-Web-App.drawio.png" alt="Google Text to Speech with Google Cloud Run">
            </v-img>
          </v-col>
        </v-row>

        <v-overlay :value="loading">
          <v-progress-circular indeterminate size="64"></v-progress-circular>
        </v-overlay>
      </v-container>
    </v-main>

  </v-app>
</template>

<script>
  import SynthesizeForm from './components/Form'
  import AppBar from './components/AppBar'
  import NavDrawer from './components/NavDrawer'
  import History from './components/History'

  import {
    signInAnonymously,
    onAuthStateChanged
  } from "firebase/auth"

  import {
    auth
  } from "./shared/firebaseConfig"


  export default {
    name: 'App',

    components: {
      SynthesizeForm,
      AppBar,
      NavDrawer,
      History
    },

    data: () => ({
      drawer: false,
      user: {},
      currentTab: "Synthesize",
      ttsLanguages: {},
      loading: false,
    }),

    methods: {
      onDrawerClick(v) {
        this.drawer = v
      },
      onFormLoading(v) {
        console.log(v)
        this.loading = v
      },
      login() {
        signInAnonymously(auth)
          .then((result) => {
            console.log(result)
          }).catch((error) => {
            console.log(error)
          })
      },
      async getVoices() {

        this.loading = true
        let token = await this.user.getIdToken()
        let headers = {
          Authorization: `Bearer ${token}`
        }
        fetch("/api/voices", {
            headers: headers
          })
          .then((res) => res.json())
          .then((data) => {
            console.log(data)
            this.ttsLanguages = data
            this.loading = false
          })
      },
      onTabSelect(tab) {
        console.log(tab)
        this.currentTab = tab
      }
    },
    created() {
      this.login()
      onAuthStateChanged(auth, (user) => {
        if (user) {
          // User is signed in, see docs for a list of available properties
          // https://firebase.google.com/docs/reference/js/firebase.User
          this.user = user
          this.getVoices()
          // ...
        } else {
          this.user = {}
          // User is signed out
          // ...
        }
      })
    }
  }
</script>