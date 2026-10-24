// @ts-check
// Kit effects. In a page: <script type="module" src="kit/effects/auto.js"></script>
export { initRise } from './rise.js';
export { initCountUp, countUp, formatCount } from './count-up.js';
export { initHoverPlate, PLATE_TARGETS } from './hover-plate.js';
export { motionBlocked } from './motion.js';
import { initRise } from './rise.js';
import { initCountUp } from './count-up.js';
import { initHoverPlate } from './hover-plate.js';

/** Starts every effect found under root. Blur-in needs no script. @param {ParentNode} [root] */
export function initEffects(root = document) {
  initRise(root);
  initCountUp(root);
  initHoverPlate(root);
}
