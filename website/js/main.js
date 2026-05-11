/* ==========================================================================
   Groeiwijze - Main JavaScript
   ========================================================================== */

(function () {
  "use strict";

  const navToggle = document.querySelector(".nav-toggle");
  const nav = document.querySelector(".nav");

  if (!navToggle || !nav) return;

  function closeNav() {
    nav.classList.remove("nav--open");
    document.body.classList.remove("nav-open");
    navToggle.classList.remove("nav-toggle--active");
    navToggle.setAttribute("aria-expanded", "false");
  }

  navToggle.addEventListener("click", function () {
    const isOpen = nav.classList.toggle("nav--open");
    document.body.classList.toggle("nav-open", isOpen);
    navToggle.classList.toggle("nav-toggle--active", isOpen);
    navToggle.setAttribute("aria-expanded", String(isOpen));
  });

  nav.querySelectorAll(".nav__link").forEach(function (link) {
    link.addEventListener("click", closeNav);
  });

  document.addEventListener("click", function (e) {
    if (!nav.contains(e.target) && !navToggle.contains(e.target)) {
      closeNav();
    }
  });

  document.addEventListener("keydown", function (e) {
    if (e.key === "Escape" && nav.classList.contains("nav--open")) {
      closeNav();
      navToggle.focus();
    }
  });
})();
