import fs from "node:fs";

fs.mkdirSync("./dist/theme", { recursive: true });
fs.copyFileSync("./src/theme/lumaTheme.ts", "./dist/theme/lumaTheme.ts");
fs.copyFileSync("./src/theme/lumaTheme.ts", "./dist/theme/lumaTheme.js");
