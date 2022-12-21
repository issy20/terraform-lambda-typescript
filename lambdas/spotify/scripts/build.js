const {build} = require('esbuild')
const tsconfig = 'tsconfig-esbuild.json'
let watch = false
if(process.argv[2] === '--watch') {
  watch = true
}

const entryPoints = ['./src/index.ts']

build({
  entryPoints,
  bundle: true,
  minify: true,
  sourcemap: true,
  outfile: 'dist/index.js',
  platform: 'node',
  external: [],
  watch,
  tsconfig
})

// "build": "esbuild index.ts --bundle --minify --sourcemap --platform=node --target=es2020 --outfile=dist/index.js",
