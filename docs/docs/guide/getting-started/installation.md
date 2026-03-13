## Usage

1. Add the Luma UI theme file in your tailwind.config.cjs file as shown below:

```ts
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./index.html",
    "./src/**/*.{vue,js,ts,jsx,tsx}",
    "node_modules/luma-vue/dist/theme/*.{js,jsx,ts,tsx,vue}",
  ],
  darkMode: "class",
  theme: {
    extend: {},
  },
  plugins: [],
};
```

### Component registration

With Luma UI, you have the flexibility to register components precisely as you wish:

### Import All Components

To import all the components provided by `Luma UI`, add `LumaUI` in your main entry file as shown below:

```ts
import { createApp } from "vue";
import App from "./App.vue";
import lumaTheme from "luma-vue/dist/theme/lumaTheme";
import LumaUI from "luma-vue";

const app = createApp(App);
app.use(LumaUI, lumaTheme);
app.mount("#app");
```

::: danger
Be warned. By doing this, you are importing all the components that are provided by Luma UI and in your final bundle all the components including the ones you didn't use will be bundled.
:::

### Individual Components with Tree Shaking

Probably you might not want to globally register all the components but instead only import the components that you need. You can achieve this by doing the following:

1. Import the `createLumaUI` option as well as the components you need as shown below:

```ts
import { createApp } from "vue";
import "./style.css";
import App from "./App.vue";
import lumaTheme from "luma-vue/dist/theme/lumaTheme";

import { WKbd, createLumaUI } from "luma-vue"; // [!code ++]

import LumaUI from "luma-vue"; // [!code --]

const app = createApp(App);

const UI = createLumaUI({
  // [!code ++]
  prefix: "T", // [!code ++]
  components: [WKbd], // [!code ++]
}); // [!code ++]

app.use(UI, lumaTheme); // [!code ++]

app.use(LumaUI, lumaTheme); // [!code --]

app.mount("#app");
```

2. Now you can use the component as shown below:

```js
<template>
  <div>
    <TKbd>K</TKbd>
  </div>
</template>
```

:::tip
The `prefix` option is only available for individual component imports.
:::

### Auto Imports with Tree Shaking

**Luma UI** comes with an intelligent resolver that automatically imports only used components.

This is made possible by leveraging a tool known as [unplugin-vue-components](https://github.com/antfu/unplugin-vue-components) which lets you auto import components on demand thus omitting import statements and still get the benefits of tree shaking.

To achieve this you need to do the following:

1. Install the `unplugin-vue-components` package by running one of the following commands:

::: code-group

```bash [pnpm]
pnpm add -D unplugin-vue-components
```

```bash [yarn]
yarn add -D unplugin-vue-components
```

```bash [npm]
npm i -D unplugin-vue-components
```

:::

2. Head over to your `main.ts` or `main.js` file and set `registerComponents` to `false` as shown below:

```ts
import { createApp } from "vue";
import "./style.css";
import App from "./App.vue";
import lumaTheme from "luma-vue/dist/theme/lumaTheme";

import { WKbd, createLumaUI } from "luma-vue"; // [!code --]

import { createLumaUI } from "luma-vue"; // [!code ++]

import LumaUI from "luma-vue"; // [!code --]

const app = createApp(App);

const UI = createLumaUI({
  // [!code --]
  prefix: "T", // [!code --]
  components: [WKbd], // [!code --]
}); // [!code --]

const UI = createLumaUI({
  // [!code ++]
  registerComponents: false, // [!code ++]
}); // [!code ++]

app.use(UI, lumaTheme); // [!code ++]

app.use(LumaUI, lumaTheme); // [!code --]

app.mount("#app");
```

3. Head over to your `vite.config.ts` or `vite.config.js` file and add the following:

```ts
// other imports
import { LumaUIComponentResolver } from "luma-vue";
import Components from "unplugin-vue-components/vite";

export default defineConfig({
  plugins: [
    // other plugins
    Components({
      resolvers: [LumaUIComponentResolver()],
    }),
  ],
});
```

4. Now you can simply use any component that you want and it will be auto imported on demand ✨

```js
<template>
  <div>
    <WKbd>K</WKbd>
  </div>
</template>
```

## Troubleshooting TypeScript Error

If you're encountering the TypeScript error: **Cannot find module 'luma-vue/dist/theme/lumaTheme' or its corresponding type declarations**, you can follow these steps to resolve it:

1. Create a `luma-vue.d.ts` declaration file in your `src` directory and inside it paste the following code:

```ts
declare module "luma-vue/dist/theme/lumaTheme";
```

The error should now be resolved.

This issue is set to be fixed in the next release of **Luma UI v0.0.1 Alpha**

🥳 Well done, you can now go ahead and build your web application with ease.
