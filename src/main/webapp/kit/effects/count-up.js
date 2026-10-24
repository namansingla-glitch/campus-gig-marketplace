// @ts-check
// Count Up: counts [data-count] from zero to its real value when it scrolls into view.
// The real number is already written in the page, so with scripts off, reduced motion or the
// Motion toggle off, people simply see it. data-rupee formats with ₹ and Indian grouping.
import { motionBlocked } from './motion.js';

/** @param {number} n @param {boolean} rupee */
export const formatCount = (n, rupee) => (rupee ? '₹' : '') + Math.round(n).toLocaleString('en-IN');

/** Strong ease-out, matching --kit-easing-out in feel. @param {number} t */
const easeOut = (t) => 1 - Math.pow(1 - t, 4);

/** @param {HTMLElement} el @param {number} [duration] */
export function countUp(el, duration = 1200) {
  const to = Number(el.dataset.count);
  const rupee = el.hasAttribute('data-rupee');
  if (!Number.isFinite(to)) return;
  if (motionBlocked(el)) { el.textContent = formatCount(to, rupee); return; }
  /** @type {number | undefined} */
  let start;
  /** @param {number} now */
  const step = (now) => {
    start ??= now;
    const t = Math.min(1, (now - start) / duration);
    el.textContent = formatCount(to * easeOut(t), rupee);
    if (t < 1) requestAnimationFrame(step);
  };
  requestAnimationFrame(step);
}

/** @param {ParentNode} [root] */
export function initCountUp(root = document) {
  /** @type {HTMLElement[]} */
  const els = [...root.querySelectorAll('[data-count]')].filter((e) => e instanceof HTMLElement);
  if (!('IntersectionObserver' in window)) return;
  const io = new IntersectionObserver((entries) => {
    for (const e of entries) {
      if (!e.isIntersecting) continue;
      io.unobserve(e.target);
      countUp(/** @type {HTMLElement} */ (e.target));
    }
  }, { threshold: 0.4 });
  els.forEach((el) => io.observe(el));
  return () => io.disconnect();
}
