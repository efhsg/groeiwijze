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

/* Dynamische terug-knop — schrijft href + tekst op basis van document.referrer.
   HTML-fallback (bestaande href en tekst) blijft staan bij directe binnenkomst,
   externe referrer, zelfde-pagina referrer, onbekend pad, of als de referrer
   zelf ook een back-link pagina is (voorkomt ping-pong tussen leaf-pagina's). */
(function () {
  "use strict";

  var backLinks = document.querySelectorAll("[data-back-link]");
  if (!backLinks.length) return;

  if (!document.referrer) return;

  var referrerUrl;
  try {
    referrerUrl = new URL(document.referrer);
  } catch (e) {
    return;
  }

  if (referrerUrl.origin !== window.location.origin) return;
  if (referrerUrl.pathname === window.location.pathname) return;

  var backLinkPages = [
    "/werkvormen.html",
    "/veelgestelde-vragen.html",
  ];
  if (backLinkPages.indexOf(referrerUrl.pathname) !== -1) return;

  var pageTitles = {
    "/": "Home",
    "/index.html": "Home",
    "/is-dit-voor-jou.html": "Is dit voor jou?",
    "/hoe-ik-werk.html": "Hoe ik werk",
    "/werkvormen.html": "Werkvormen",
    "/over-mij.html": "Over mij",
    "/tarieven.html": "Tarieven",
    "/contact.html": "Contact",
    "/veelgestelde-vragen.html": "Veelgestelde vragen",
    "/herstelroute.html": "Weg naar herstel",
    "/visie.html": "Mijn visie",
    "/verwijzers.html": "Voor verwijzers",
    "/privacy.html": "Privacy",
  };

  var title = pageTitles[referrerUrl.pathname];
  if (!title) return;

  backLinks.forEach(function (link) {
    link.href = referrerUrl.pathname + referrerUrl.search;
    link.textContent = "Terug naar " + title;
  });
})();
