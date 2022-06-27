<template>
  <v-card>
    <v-container>

      <v-list two-line>
        <v-header>History</v-header>

        <v-list-item v-for="(item,key) in items" :key="key">
          <v-list-item-avatar>
            <v-icon class="blue lighten-1" dark @click="play(key)">
              mdi-play
            </v-icon>
          </v-list-item-avatar>

          <v-list-item-content>
            <v-list-item-title v-text="item.text"></v-list-item-title>
            <v-list-item-subtitle>{{item.voiceName}} - {{item.gender}} - {{item.audioEncoding}}</v-list-item-subtitle>
          </v-list-item-content>

          <v-list-item-action>
            <v-btn icon>
              <v-icon color="grey lighten-1">mdi-information</v-icon>
            </v-btn>
          </v-list-item-action>
        </v-list-item>
      </v-list>
    </v-container>
  </v-card>
</template>

<script>
  import Vue from 'vue'

  import {
    db,
    storage,
  } from "../shared/firebaseConfig"
  import {
    collection,
    onSnapshot,
    query,
    where,
  } from "firebase/firestore"
  import {
    ref,
    getBlob,
  } from "firebase/storage"

  export default {
    name: "History",

    props: {
      user: {
        default: function () {
          return null
        }
      },
    },
    data: () => ({
      items: {},
      items2: {
        "1": {
          text: "hello there",
          gender: "female",
          voiceName: "bg-bg-Standard",
          gcsRef: "gs://tts-utility-354320.appspot.com/3a13d934-8159-476b-b35e-444a6fbf679a/output.mp3"
        },
        "2": {
          text: "hello there",
        },
        "3": {
          text: "hello there",
        },
        "4": {
          text: "hello there",
        },
      }
    }),

    computed: {
      history() {
        return this.items
      }
    },

    created() {
      const q = query(collection(db, "history"), where("userId", "==", this.user.uid))
      onSnapshot(q, (snapshot) => {
        console.log(snapshot)
        snapshot.docChanges().forEach((change) => {
          console.log(change.type)
          if (change.type == "added") {
            Vue.set(this.items, change.doc.id, change.doc.data())
          }
        })
      })
    },

    methods: {
      async play(v) {
        console.log(v)
        if (!this.items[v].audio) {
          let blob = await getBlob(ref(storage, this.items[v].gcsRef))
          let url = URL.createObjectURL(blob)
          this.items[v].audio = new Audio(url)
        }

        this.items[v].audio.play()
      },
    },
    watch: {
      items(v) {
        console.log(v)
      }
    }
  }
</script>