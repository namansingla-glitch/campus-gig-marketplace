// @ts-check
// Split-text rise: wraps each word of [data-kit-rise] so CSS can lift it from a baseline, 60 ms apart.
// Keeps nested elements (e.g. mixed-scale spans). Without JS the headline is plain text. Screen readers
// get the whole sentence from aria-label; the word spans are hidden from them.
// Reduced motion: CSS turns the rise into a 200 ms fade. Motion toggle off: no animation at all.

/** @param {ParentNode} [root] */
export function initRise(root = document) {
  /** @type {NodeListOf<HTMLElement>} */
  const els = root.querySelectorAll('[data-kit-rise]');
  els.forEach((el) => {
    if (!el.dataset.kitRiseSource) el.dataset.kitRiseSource = el.innerHTML;
    else el.innerHTML = el.dataset.kitRiseSource;
    el.setAttribute('aria-label', (el.textContent ?? '').replace(/\s+/g, ' ').trim());
    let i = 0;
    const walker = document.createTreeWalker(el, NodeFilter.SHOW_TEXT);
    /** @type {Text[]} */
    const texts = [];
    while (walker.nextNode()) texts.push(/** @type {Text} */ (walker.currentNode));
    for (const t of texts) {
      const parts = (t.textContent ?? '').split(/(\s+)/);
      const frag = document.createDocumentFragment();
      for (const p of parts) {
        if (!p) continue;
        if (/^\s+$/.test(p)) { frag.append(document.createTextNode(' ')); continue; }
        const w = document.createElement('span');
        w.className = 'k-rise__w';
        w.setAttribute('aria-hidden', 'true');
        const inner = document.createElement('span');
        inner.style.setProperty('--k-i', String(i++));
        inner.textContent = p;
        w.append(inner);
        frag.append(w);
      }
      t.replaceWith(frag);
    }
    el.classList.add('k-rise--ready');
  });
}
