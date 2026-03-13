import type { App } from "vue";
import "./assets/css/tailwind.css";
import type { LumaUIConfiguration } from "./Types/variant";

const defaultOptions: LumaUIOptions = {
  prefix: "W",
  registerComponents: true,
};

export interface LumaUIOptions {
  prefix?: string;
  components?: any;
  theme?: any;
  registerComponents?: boolean;
}

function create(createOptions: LumaUIOptions = {}) {
  const install = (app: App, installOptions: LumaUIConfiguration) => {
    const options = {
      ...defaultOptions,
      ...createOptions,
      ...installOptions,
    };
    if (options.registerComponents) {
      if (options.components) {
        options.components.forEach((component: any) => {
          const name = component.name.startsWith("W")
            ? component.name.slice(1)
            : component.name;

          app.component(`${options.prefix}${name}`, component);
        });
      }
    }
    app.provide("config", installOptions);
  };

  return {
    install,
  };
}

export default create;
