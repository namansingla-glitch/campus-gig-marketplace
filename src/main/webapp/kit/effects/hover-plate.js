// @ts-check
// Hover plate (replaced the target cursor, Naman 23 Oct): the system cursor is never replaced.
// Over a target inside [data-kit-plate], a soft plate fades in behind it in the target's own corner
// radius + 6 px, and slides when the pointer moves to the next target. Mouse/trackpad only; off on
// touch screens, with reduced motion and with the Motion toggle.
import { motionBlocked } from './motion.js';

export const PLATE_TARGETS = '.k-btn:not(:disabled):not([aria-disabled="true"]), a.k-gig, [data-kit-target]';
const PAD = 6;

/** @param {ParentNode} [root] */
export function initHoverPlate(root = document) {
  /** @type {NodeListOf<HTMLElement>} */
  const scopes = root.querySelectorAll('[data-kit-plate]');
  const fine = matchMedia('(hover: hover) and (pointer: fine)');
  /** @type {(() => void)[]} */
  const cleanups = [];
  scopes.forEach((scope) => {
    let plate = /** @type {HTMLElement | null} */ (scope.querySelector(':scope > .k-plate'));
    if (!plate) {
      plate = document.createElement('div');
      plate.className = 'k-plate';
      plate.setAttribute('aria-hidden', 'true');
      scope.prepend(plate);
    }
    const p = plate;
    /** @type {HTMLElement | null} */
    let locked = null;
    /** @param {HTMLElement} t @param {boolean} jump */
    const place = (t, jump) => {
      const r = t.getBoundingClientRect();
      const radius = Math.min((parseFloat(getComputedStyle(t).borderTopLeftRadius) || 0) + PAD, 999);
      if (jump) p.classList.add('k-plate--jump');
      p.style.transform = `translate(${r.left - PAD}px, ${r.top - PAD}px)`;
      p.style.width = `${r.width + PAD * 2}px`;
      p.style.height = `${r.height + PAD * 2}px`;
      p.style.borderRadius = `${radius}px`;
      if (jump) { void p.offsetWidth; p.classList.remove('k-plate--jump'); }
    };
    const hide = () => { locked = null; p.classList.remove('k-plate--on'); };
    /** @param {PointerEvent} e */
    const over = (e) => {
      if (!fine.matches || motionBlocked(scope) || e.pointerType === 'touch') return hide();
      const t = /** @type {HTMLElement | null} */ (/** @type {Element} */ (e.target).closest(PLATE_TARGETS));
      if (t === locked) return;
      if (t && scope.contains(t)) { place(t, !locked); locked = t; p.classList.add('k-plate--on'); }
      else hide();
    };
    const follow = () => { if (locked) place(locked, true); };
    scope.addEventListener('pointerover', over, { passive: true });
    scope.addEventListener('pointerleave', hide);
    addEventListener('scroll', follow, { passive: true });
    addEventListener('resize', follow, { passive: true });
    cleanups.push(() => {
      scope.removeEventListener('pointerover', over);
      scope.removeEventListener('pointerleave', hide);
      removeEventListener('scroll', follow);
      removeEventListener('resize', follow);
      p.remove();
    });
  });
  return () => cleanups.forEach((c) => c());
}
