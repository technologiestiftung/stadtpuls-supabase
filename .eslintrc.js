module.exports =
  {
    env: { browser: false, es2021: true, node: true, "jest/globals": true },
    extends: [
      "eslint:recommended",
      "plugin:@typescript-eslint/recommended",
      "prettier",
      "plugin:jest/recommended",
    ],
    parser: "@typescript-eslint/parser",
    parserOptions: { ecmaVersion: 13, sourceType: "module" },
    plugins: ["@typescript-eslint", "jest", "prettier"],
    rules: {},
  };
