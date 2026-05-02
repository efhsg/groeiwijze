/* ==========================================================================
   Groeiwijze - Main JavaScript
   ========================================================================== */

(function () {
  "use strict";

  // Mobile navigation toggle
  const navToggle = document.querySelector(".nav-toggle");
  const nav = document.querySelector(".nav");

  if (navToggle && nav) {
    navToggle.addEventListener("click", function () {
      const isOpen = nav.classList.toggle("nav--open");
      navToggle.classList.toggle("nav-toggle--active");
      navToggle.setAttribute("aria-expanded", isOpen);
    });

    // Close menu when clicking a link
    nav.querySelectorAll(".nav__link").forEach(function (link) {
      link.addEventListener("click", function () {
        nav.classList.remove("nav--open");
        navToggle.classList.remove("nav-toggle--active");
        navToggle.setAttribute("aria-expanded", "false");
      });
    });
  }

  // Close menu when clicking outside
  document.addEventListener("click", function (e) {
    if (nav && navToggle && !nav.contains(e.target) && !navToggle.contains(e.target)) {
      nav.classList.remove("nav--open");
      navToggle.classList.remove("nav-toggle--active");
      navToggle.setAttribute("aria-expanded", "false");
    }
  });
})();
