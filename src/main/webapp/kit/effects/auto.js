// @ts-check
// Drop-in: starts all kit effects once the page has loaded.
import { initEffects } from './index.js';

if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', () => initEffects(), { once: true });
else initEffects();
