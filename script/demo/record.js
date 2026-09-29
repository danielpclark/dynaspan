// Records the frames for the README demo GIF.
//
//   PORT=3999 bin/demo &
//   node script/demo/record.js            # writes script/demo/frames/
//   python3 script/demo/build_gif.py      # writes docs/images/*.gif / *.png
//
// Requires Playwright (`npm install -g playwright` or `npx playwright`).
const fs = require('fs');
const path = require('path');
const { chromium } = require('playwright');

const BASE_URL = process.env.DEMO_URL || `http://localhost:${process.env.PORT || 3999}/`;
const FRAMES = path.join(__dirname, 'frames');
const STILLS = path.join(__dirname, '..', '..', 'docs', 'images');
const VIEWPORT = { width: 760, height: 520 };

const OVERLAY = `
  #demo-cursor { position: fixed; left: 0; top: 0; z-index: 10000; pointer-events: none;
    width: 22px; height: 22px; transform-origin: 3px 3px; filter: drop-shadow(0 1px 2px rgba(0,0,0,.35)); }
  #demo-cursor.down { transform: scale(0.85); }
  #demo-ripple { position: fixed; z-index: 9999; pointer-events: none; width: 36px; height: 36px;
    margin: -18px 0 0 -18px; border-radius: 50%; background: rgba(59,130,246,.35); opacity: 0; }
  #demo-caption { position: fixed; left: 50%; bottom: 22px; transform: translateX(-50%); z-index: 9998;
    padding: 8px 16px; border-radius: 999px; background: #0f172a; color: #fff; white-space: nowrap;
    font: 600 14px/1.4 -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; }
  #demo-caption:empty { display: none; }
  #demo-caption kbd { font: inherit; padding: 0 6px; border-radius: 4px; background: rgba(255,255,255,.18); }
`;

const CURSOR_SVG = `<svg id="demo-cursor" viewBox="0 0 22 22" xmlns="http://www.w3.org/2000/svg">
  <path d="M3 2 L3 18 L7.5 14 L10.5 20.5 L13 19.4 L10.1 13 L16 13 Z" fill="#0f172a" stroke="#fff" stroke-width="1.4" stroke-linejoin="round"/>
</svg>`;

(async () => {
  fs.rmSync(FRAMES, { recursive: true, force: true });
  fs.mkdirSync(FRAMES, { recursive: true });
  fs.mkdirSync(STILLS, { recursive: true });

  const browser = await chromium.launch({ executablePath: process.env.BROWSER_PATH || undefined });
  const page = await browser.newPage({ viewport: VIEWPORT, deviceScaleFactor: 1 });
  await page.goto(BASE_URL);
  await page.addStyleTag({ content: OVERLAY });
  await page.evaluate((svg) => {
    document.body.insertAdjacentHTML('beforeend', svg + '<div id="demo-ripple"></div><div id="demo-caption"></div>');
  }, CURSOR_SVG);

  const frames = [];
  let cursor = { x: VIEWPORT.width - 60, y: VIEWPORT.height - 80 };

  async function snap(duration) {
    const file = path.join(FRAMES, `frame-${String(frames.length).padStart(4, '0')}.png`);
    await page.screenshot({ path: file });
    frames.push({ file: path.basename(file), duration });
  }

  async function placeCursor({ x, y }, down = false) {
    await page.evaluate(({ x, y, down }) => {
      const el = document.getElementById('demo-cursor');
      el.style.left = `${x - 3}px`;
      el.style.top = `${y - 2}px`;
      el.classList.toggle('down', down);
    }, { x, y, down });
  }

  async function caption(html) {
    await page.evaluate((html) => { document.getElementById('demo-caption').innerHTML = html; }, html);
  }

  async function textPoint(selector, where = 'center') {
    return page.evaluate(({ selector, where }) => {
      const el = document.querySelector(selector);
      const range = document.createRange();
      range.selectNodeContents(el);
      const rects = range.getClientRects();
      const rect = where === 'end' ? rects[rects.length - 1] : rects[0];
      const x = where === 'end' ? rect.right - 4 : rect.left + Math.min(rect.width / 2, 90);
      return { x: Math.round(x), y: Math.round(rect.top + rect.height / 2) };
    }, { selector, where });
  }

  async function moveTo(target, steps = 16) {
    const start = cursor;
    for (let i = 1; i <= steps; i++) {
      const t = i / steps;
      const ease = t < 0.5 ? 2 * t * t : 1 - Math.pow(-2 * t + 2, 2) / 2;
      const point = { x: start.x + (target.x - start.x) * ease, y: start.y + (target.y - start.y) * ease };
      await page.mouse.move(point.x, point.y);
      await placeCursor(point);
      await snap(30);
    }
    cursor = target;
  }

  async function click() {
    await placeCursor(cursor, true);
    await page.evaluate(({ x, y }) => {
      const ripple = document.getElementById('demo-ripple');
      ripple.style.left = `${x}px`;
      ripple.style.top = `${y}px`;
      ripple.style.opacity = '1';
    }, cursor);
    await snap(90);
    await page.mouse.down();
    await page.mouse.up();
    await placeCursor(cursor);
    await page.evaluate(() => { document.getElementById('demo-ripple').style.opacity = '0'; });
    await page.waitForTimeout(60);
  }

  async function type(text) {
    for (const character of text) {
      await page.keyboard.type(character);
      await snap(character === ' ' ? 90 : 55);
    }
  }

  async function waitForSave(uid) {
    await page.waitForSelector(`#dyna_span_block${uid}:not(.ds-saving)`);
    await page.waitForSelector('#toast.toast-visible');
    await page.waitForTimeout(250);
  }

  async function still(name, selector) {
    const box = await page.locator(selector).boundingBox();
    const pad = 24;
    await page.screenshot({
      path: path.join(STILLS, name),
      clip: { x: box.x - pad, y: box.y - pad, width: box.width + pad * 2, height: box.height + pad * 2 }
    });
  }

  // 1. Plain text on the page.
  await placeCursor(cursor);
  await caption('Dynaspan fields look like regular text');
  await snap(1600);
  await page.evaluate(() => { document.getElementById('demo-cursor').style.display = 'none'; });
  await still('dynaspan-text.png', '.card');
  await page.evaluate(() => { document.getElementById('demo-cursor').style.display = ''; });

  // 2. Click the text and it becomes an input.
  await moveTo(await textPoint('#dyna_span_spantitle'));
  await snap(500);
  await caption('Click the text and it becomes an input');
  await click();
  await snap(700);
  await page.keyboard.press('Control+A');
  await snap(350);
  await type('Mathematician & Writer');
  await snap(500);
  await page.evaluate(() => { document.getElementById('demo-cursor').style.display = 'none'; });
  await still('dynaspan-editing.png', '.card');
  await page.evaluate(() => { document.getElementById('demo-cursor').style.display = ''; });

  // 3. Click away: it saves over AJAX and turns back into text.
  await caption('Click away: it saves over AJAX and turns back into text');
  await moveTo({ x: 640, y: 150 });
  await click();
  await waitForSave('title');
  await snap(1800);

  // 4. Selects work the same way.
  await caption('Works with selects…');
  await moveTo(await textPoint('#dyna_span_spanrole'));
  await snap(300);
  await click();
  await snap(600);
  await page.selectOption('#dyna_span_field_val_role', 'editor');
  await snap(800);
  await moveTo({ x: 640, y: 225 }, 12);
  await click();
  await waitForSave('role');
  await snap(1300);

  // 5. ...and text areas. Enter saves, Escape cancels.
  await caption('…and text areas. <kbd>Enter</kbd> saves, <kbd>Esc</kbd> cancels');
  await moveTo(await textPoint('#dyna_span_spanbio', 'end'));
  await snap(300);
  await click();
  await page.keyboard.press('Control+End');
  await snap(500);
  await type(' She saw machines could do more than math.');
  await snap(500);
  await moveTo({ x: 640, y: 150 }, 14);
  await click();
  await waitForSave('bio');
  await snap(1400);
  await caption('');
  await moveTo({ x: VIEWPORT.width - 60, y: VIEWPORT.height - 80 }, 12);
  await snap(2400);

  fs.writeFileSync(path.join(FRAMES, 'frames.json'), JSON.stringify(frames, null, 2));
  console.log(`Captured ${frames.length} frames`);
  await browser.close();
})().catch((error) => {
  console.error(error);
  process.exit(1);
});
