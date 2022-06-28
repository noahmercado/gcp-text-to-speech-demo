<template>

  <v-navigation-drawer v-model="drawer" absolute temporary>
    <v-list nav dense>
      <v-list-item-group v-model="group" active-class="deep-purple--text text--accent-4">
        <v-list-item>
          <v-list-item-icon>
            <v-icon>mdi-home</v-icon>
          </v-list-item-icon>
          <v-list-item-title>Home</v-list-item-title>
        </v-list-item>

        <v-list-item>
          <v-list-item-icon>
            <v-icon>mdi-account</v-icon>
          </v-list-item-icon>
          <v-list-item-title>Account</v-list-item-title>
        </v-list-item>
      </v-list-item-group>
    </v-list>
  </v-navigation-drawer>
</template>

<script>
  export default {
    name: "NavDrawer",

    props: {
      drawer: {
        default: function () {
          return false
        },
        group: {
          default: function () {
            return null
          },
        }
      },
    },
    data: () => ({
      group: {}
    }),

    methods: {
      // 
    },
    watch: {
      drawer: function (val) {
        this.$emit("onDrawerClick", val)
      },
      group: function (val) {
        console.log(`${val} was selected!`)
      }
    },
  };
</script>
<style scoped>
  .video_container {
    width: 100% !important;
    height: auto !important;
  }
</style>