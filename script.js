const navToggle = document.querySelector(".nav-toggle");
const siteNav = document.querySelector(".site-nav");

const closeNav = () => {
  if (!siteNav || !navToggle) {
    return;
  }
  siteNav.classList.remove("is-open");
  navToggle.setAttribute("aria-expanded", "false");
};

const toggleNav = () => {
  if (!siteNav || !navToggle) {
    return;
  }
  const isOpen = siteNav.classList.toggle("is-open");
  navToggle.setAttribute("aria-expanded", String(isOpen));
};

if (navToggle) {
  navToggle.addEventListener("click", toggleNav);
}

if (siteNav) {
  siteNav.querySelectorAll("a").forEach((link) => {
    link.addEventListener("click", closeNav);
  });
}

document.addEventListener("click", (event) => {
  if (!siteNav || !navToggle) {
    return;
  }
  const target = event.target;
  if (
    siteNav.classList.contains("is-open") &&
    target instanceof Node &&
    !siteNav.contains(target) &&
    !navToggle.contains(target)
  ) {
    closeNav();
  }
});
