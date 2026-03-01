const navToggle = document.querySelector(".nav-toggle");
const primaryNav =
  document.querySelector(".site-nav") || document.querySelector(".nav-links");
const navOpenClass =
  primaryNav && primaryNav.classList.contains("site-nav") ? "is-open" : "open";

const closeNav = () => {
  if (!primaryNav || !navToggle) {
    return;
  }
  primaryNav.classList.remove(navOpenClass);
  navToggle.setAttribute("aria-expanded", "false");
};

const toggleNav = () => {
  if (!primaryNav || !navToggle) {
    return;
  }
  const isOpen = primaryNav.classList.toggle(navOpenClass);
  navToggle.setAttribute("aria-expanded", String(isOpen));
};

if (navToggle && primaryNav) {
  navToggle.addEventListener("click", toggleNav);
  primaryNav.querySelectorAll("a").forEach((link) => {
    link.addEventListener("click", closeNav);
  });
}

document.addEventListener("click", (event) => {
  if (!primaryNav || !navToggle) {
    return;
  }
  const target = event.target;
  if (
    primaryNav.classList.contains(navOpenClass) &&
    target instanceof Node &&
    !primaryNav.contains(target) &&
    !navToggle.contains(target)
  ) {
    closeNav();
  }
});

const navbar = document.querySelector("#navbar");
if (navbar) {
  const syncNavbarState = () => {
    navbar.classList.toggle("scrolled", window.scrollY > 10);
  };
  syncNavbarState();
  window.addEventListener("scroll", syncNavbarState, { passive: true });
}

const revealTargets = document.querySelectorAll(".reveal");
const prefersReducedMotion =
  window.matchMedia &&
  window.matchMedia("(prefers-reduced-motion: reduce)").matches;

if (
  "IntersectionObserver" in window &&
  revealTargets.length > 0 &&
  !prefersReducedMotion
) {
  document.documentElement.classList.add("reveal-ready");
  const revealObserver = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.classList.add("visible");
          revealObserver.unobserve(entry.target);
        }
      });
    },
    { threshold: 0.12 }
  );
  revealTargets.forEach((target) => {
    if (target.getBoundingClientRect().top < window.innerHeight * 0.95) {
      target.classList.add("visible");
    }
    revealObserver.observe(target);
  });
} else if (revealTargets.length > 0) {
  document.documentElement.classList.remove("reveal-ready");
  revealTargets.forEach((target) => target.classList.add("visible"));
}

const contactForm =
  document.querySelector("#contact-form") || document.querySelector("#contactForm");

if (contactForm) {
  const statusEl =
    contactForm.querySelector(".form-status") ||
    document.querySelector("#formStatus") ||
    document.querySelector(".form-status");
  const submitBtn = contactForm.querySelector('button[type="submit"]');

  const setStatus = (message, state) => {
    if (!statusEl) {
      return;
    }
    statusEl.textContent = message;
    statusEl.classList.remove("success", "error", "is-error");
    if (state === "success") {
      statusEl.classList.add("success");
    }
    if (state === "error") {
      statusEl.classList.add("error", "is-error");
    }
  };

  contactForm.addEventListener("submit", async (event) => {
    event.preventDefault();

    const endpoint =
      contactForm.getAttribute("data-endpoint") ||
      contactForm.getAttribute("action") ||
      "/api/contact";
    const formData = new FormData(contactForm);
    const payload = {
      name: formData.get("name"),
      email: formData.get("email"),
      message: formData.get("message"),
      interest: formData.get("interest") || "",
    };

    const originalButtonText = submitBtn ? submitBtn.textContent || "" : "";
    if (submitBtn) {
      submitBtn.disabled = true;
      submitBtn.textContent = "Sending...";
    }
    setStatus("", undefined);

    try {
      const response = await fetch(endpoint, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload),
      });

      if (!response.ok) {
        const { error } = await response.json().catch(() => ({}));
        throw new Error(
          error ||
            "Something went wrong. Please email us directly at htaplus@htaplus.com."
        );
      }

      setStatus("Thanks! Your message has been sent.", "success");
      contactForm.reset();
    } catch (error) {
      const message =
        error instanceof Error
          ? error.message
          : "Something went wrong. Please email us directly at htaplus@htaplus.com.";
      setStatus(message, "error");
    } finally {
      if (submitBtn) {
        submitBtn.disabled = false;
        submitBtn.textContent = originalButtonText;
      }
    }
  });
}

const shareLinks = document.querySelectorAll("[data-share]");
if (shareLinks.length > 0) {
  const shareUrl = encodeURIComponent(window.location.href);
  const shareTitle = encodeURIComponent(document.title);

  shareLinks.forEach((link) => {
    const platform = link.getAttribute("data-share");
    let url = "";

    if (platform === "linkedin") {
      url = `https://www.linkedin.com/sharing/share-offsite/?url=${shareUrl}`;
    }

    if (platform === "x") {
      url = `https://x.com/intent/tweet?url=${shareUrl}&text=${shareTitle}`;
    }

    if (platform === "email") {
      url = `mailto:?subject=${shareTitle}&body=${shareUrl}`;
    }

    if (url) {
      link.setAttribute("href", url);
    }
  });
}
