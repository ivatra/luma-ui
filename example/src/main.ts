import "./assets/css/tailwind.css";
import { createApp } from "vue";
import App from "./App.vue";
import install from "luma-vue";
import config from "luma-vue/dist/theme/lumaTheme";
const app = createApp(App);
app.use(install, config);
app.mount("#app");
