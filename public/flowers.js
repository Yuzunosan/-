// 花のSVG部品（カウンター・操作パネル共通）
// Flowers.defs(theme) を <svg><defs> に入れると、#wr-flower / #wr-bud / #wr-leaf が使える。
(() => {
  const THEMES = {
    sakura: "桜",
    rose: "薔薇",
    kikyo: "桔梗",
    sunflower: "向日葵",
    hydrangea: "紫陽花",
  };

  // 花びら（根元が原点、上向き、長さ約20）
  const PETAL = {
    notched: "M0 0C-7-4-10-13-6-19Q-3-21 0-17Q3-21 6-19C10-13 7-4 0 0Z",
    round: "M0 0C-11-4-12-19 0-20C12-19 11-4 0 0Z",
    pointed: "M0 0C-7-6-6-14 0-21C6-14 7-6 0 0Z",
    slim: "M0-5C-3.4-9-3.4-17 0-22C3.4-17 3.4-9 0-5Z",
  };

  const ring = (d, n, { scale = 1, rot = 0, fill = "url(#wr-petal)" } = {}) =>
    Array.from({ length: n }, (_, i) =>
      `<path d="${d}" fill="${fill}" stroke="var(--p3)" stroke-opacity=".3" stroke-width=".6" transform="rotate(${rot + (i * 360) / n}) scale(${scale})"/>`
    ).join("");

  const dots = (n, r, size, fill) =>
    Array.from({ length: n }, (_, i) => {
      const a = (i / n) * Math.PI * 2;
      return `<circle cx="${(Math.cos(a) * r).toFixed(2)}" cy="${(Math.sin(a) * r).toFixed(2)}" r="${size}" fill="${fill}"/>`;
    }).join("");

  const core = (r) => `<circle r="${r}" fill="url(#wr-core)"/>`;

  const SHAPES = {
    sakura: () => ring(PETAL.notched, 5) + core(3.2) + dots(10, 6, 0.9, "var(--core2)"),
    rose: () =>
      ring(PETAL.round, 5) +
      ring(PETAL.round, 5, { scale: 0.68, rot: 36, fill: "url(#wr-petal-deep)" }) +
      ring(PETAL.round, 3, { scale: 0.4, rot: 15, fill: "var(--p3)" }) +
      `<circle r="2.4" fill="var(--p3)" stroke="var(--p1)" stroke-opacity=".5" stroke-width=".5"/>`,
    kikyo: () =>
      ring(PETAL.pointed, 5) +
      ring(PETAL.pointed, 5, { scale: 0.55, rot: 36, fill: "url(#wr-petal-deep)" }) +
      core(2.8) + dots(5, 4.6, 0.8, "var(--core2)"),
    sunflower: () =>
      ring(PETAL.slim, 16) +
      ring(PETAL.slim, 16, { scale: 0.86, rot: 11.25 }) +
      core(7.5) + dots(8, 3.6, 0.7, "var(--p3)") + dots(13, 5.8, 0.7, "var(--p3)"),
    hydrangea: () => ring(PETAL.round, 4, { scale: 0.95 }) + core(2.6) + dots(4, 4.2, 0.7, "var(--p3)"),
  };

  function defs(theme) {
    const shape = SHAPES[theme] || SHAPES.sakura;
    return `
      <radialGradient id="wr-petal" gradientUnits="userSpaceOnUse" cx="0" cy="0" r="22">
        <stop offset="0" style="stop-color:var(--p2)"/>
        <stop offset=".7" style="stop-color:var(--p1)"/>
        <stop offset="1" style="stop-color:var(--p1)"/>
      </radialGradient>
      <radialGradient id="wr-petal-deep" gradientUnits="userSpaceOnUse" cx="0" cy="0" r="22">
        <stop offset="0" style="stop-color:var(--p3)"/>
        <stop offset=".8" style="stop-color:var(--p2)"/>
      </radialGradient>
      <radialGradient id="wr-core" gradientUnits="userSpaceOnUse" cx="-1" cy="-1" r="8">
        <stop offset="0" style="stop-color:var(--core)"/>
        <stop offset="1" style="stop-color:var(--core2)"/>
      </radialGradient>
      <linearGradient id="wr-leaf-g" x1="0" x2="1">
        <stop offset="0" style="stop-color:var(--leaf2)"/>
        <stop offset="1" style="stop-color:var(--leaf)"/>
      </linearGradient>
      <g id="wr-flower">${shape()}</g>
      <g id="wr-bud">
        <path d="M0-8C3-5 3.5-1 0 2C-3.5-1-3-5 0-8Z" fill="var(--p2)"/>
        <path d="M0 3C-3 2-4-1-3.5-3C-2-1-1 0 0 0C1 0 2-1 3.5-3C4-1 3 2 0 3Z" fill="var(--leaf2)"/>
      </g>
      <path id="wr-leaf" d="M0 0C3-4 9-4 13 0C9 4 3 4 0 0Z" fill="url(#wr-leaf-g)"/>`;
  }

  window.Flowers = { THEMES, defs };
})();
