"use strict";

const themeSelect = document.querySelector("#theme-select");

themeSelect.addEventListener("change", () => {
  document.documentElement.dataset.theme = themeSelect.value;
});
