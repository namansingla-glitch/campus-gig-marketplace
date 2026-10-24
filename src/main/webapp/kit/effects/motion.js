// @ts-check
/** True when motion should not play here: the device asks for reduced motion, or a Motion toggle is off above `el`.
 * @param {Element | null | undefined} el */
export function motionBlocked(el) {
  if (typeof matchMedia === 'function' && matchMedia('(prefers-reduced-motion: reduce)').matches) return true;
  return !!(el && el.closest('[data-motion="off"]'));
}
