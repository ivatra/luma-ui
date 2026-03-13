export interface Dependency {
  pkg?: string
  version?: string
  path?: string
  source?: 'skyPack' | 'jsdelivr'
  cssPath?: string
}
export default {
  title: 'Luma-UI',
  compLibName: 'Luma-ui',
  compLibShort: 'luma',
  versionUrl: 'https://data.jsdelivr.com/v1/package/npm/',
  vueMinVersion: '3.2.0',
  compLibMinVersion: '1.0.9',
  libDeps: {} as Record<string, Dependency>,
  coreDeps: {
    vue: {
      pkg: '@vue/runtime-dom',
      version: 'latest',
      path: '/dist/runtime-dom.esm-browser.js',
      source: 'jsdelivr',
    },
    '@vue/compiler-sfc': {
      pkg: '@vue/compiler-sfc',
      version: 'latest',
      path: '/dist/compiler-sfc.esm-browser.js',
      source: 'jsdelivr',
    },
    '@vue/shared': {
      pkg: '@vue/shared',
      version: 'latest',
      path: '/dist/shared.esm-bundler.js',
      source: 'jsdelivr',
    },
    'luma-vue': {
      pkg: 'luma-vue',
      version: 'latest',
      path: '/dist/luma-vue.js',
      source: 'skyPack',
      cssPath: 'luma-vue/dist/theme/lumaTheme',
    },
  } as Record<string, Dependency>,
  cdnUrl: {
    skypack: 'https://cdn.skypack.dev/',
    jsdelivr: 'https://cdn.jsdelivr.net/npm/',
  },
  devDeps: {
    // 'luma-vue': {
    //   path: `${location.origin}/play/src/vue-ui-next-dev-proxy`,
    // },
    vue: {
      path: `${location.origin}/play/src/vue-dev-proxy`,
    },
    '@vue/compiler-sfc': {
      path: `${location.origin}/play/src/vue-sfc-dev-proxy`,
    },
    '@vue/shared': {
      path: `${location.origin}/play/src/vue-shared-dev-proxy`,
    },
  },
}
