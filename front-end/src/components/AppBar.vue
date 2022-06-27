<template>
  <v-card>
    <v-app-bar elevate-on-scroll color="#fcb69f" dark>
        <!-- src="https://picsum.photos/1920/1080?random" -->
      <template v-slot:img="{ props }">
        <v-img v-bind="props" gradient="to top right, rgba(19,84,122,.5), rgba(128,208,199,.8)"></v-img>
      </template>

      <v-app-bar-nav-icon @click="drawer = true"></v-app-bar-nav-icon>

      <v-img src="../assets/google-cloud-logo.png" max-width="400" max-height="60" ></v-img>

      <v-spacer></v-spacer>
      <v-tabs v-model="currentItem" fixed-tabs slider-color="accent" centered>
        <v-tab v-for="(text, item) in tabs" :key="item" :href="'#tab-' + item" @click="selectTab(item)">
          {{ item }}
        </v-tab>
      </v-tabs>

      <v-spacer></v-spacer>
      <v-text-field class="mr-5" filled hide-details rounded outlined dense flat dark append-icon="mdi-magnify"></v-text-field>
      <v-spacer></v-spacer>
          <v-avatar class="mr-5">
            <!-- <img :src="user.photoURL" :alt="user.displayName" v-if="user != null"> -->
            <v-icon dark >mdi-account-circle</v-icon>
          </v-avatar>
      <v-spacer></v-spacer>
      <v-btn icon>
        <v-icon>mdi-dots-vertical</v-icon>
      </v-btn>
    </v-app-bar>
  </v-card>
</template>

<script>
  export default {
    name: "AppBar",

    props: {
      drawer: {
        default: function () {
          return false
        },
      },
      group: {
        default: function () {
          return null
        },
      },
      user: {
        default: function () {
          return null
        },
      }
    },
    data: () => ({
      currentItem: "tab-Synthesize",
      tabs: {
        Synthesize: "Synthesize",
        History: "History"
      },
      more: [],
    }),

    methods: {
      addItem(tab) {
        const removed = this.tab.splice(0, 1);
        this.tab.push(...this.more.splice(this.more.indexOf(tab), 1));
        this.more.push(...removed);
        this.$nextTick(() => {
          this.currentItem = "tab-" + tab;
        });
      },
      selectTab(tab) {
        this.$emit('tabSelected', tab);
      },
    },
    watch: {
      drawer: function (val) {
        this.$emit("onDrawerClick", val)
      }
    }
  };
</script>
<style scoped>
  .video_container {
    width: 100% !important;
    height: auto !important;
  }
</style>