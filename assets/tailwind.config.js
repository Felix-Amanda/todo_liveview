/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./js/**/*.js",
    "../lib/**/*.ex",
    "../lib/**/*.heex"
  ],
  theme: { extend: {} },
  plugins: [require("daisyui")],
  daisyui: {
    themes: ["cupcake"]
  }
}
