import { createApp } from 'vue'
import App from './App.vue'
import '@vue/repl/dist/style.css'
import './assets/tailwind.css'
import '@unocss/reset/tailwind.css'
import 'uno.css'

import lumaTheme from 'luma-vue/dist/theme/lumaTheme'

import install from 'luma-vue'

// @ts-expect-error Custom window property
window.VUE_DEVTOOLS_CONFIG = {
  defaultSelectedAppId: 'repl',
}

const app = createApp(App)
app.use(install, lumaTheme)
app.mount('#play_ground')
