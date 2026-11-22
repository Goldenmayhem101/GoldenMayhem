export const logo=(name,sub='GOLDENMAYHEM')=>`<div class="logo stroke"><small>${sub}</small>${name}</div>`;
export const tag=(html)=>`<div class="tag stroke">${html}</div>`;
export const pill=(txt,css)=>`<div class="pill" style="${css}">${txt}</div>`;
export const bar=(css,pct,label)=>`<div class="bar" style="${css}"><i style="width:${pct}%"></i></div>`;
export const btn=(txt,css)=>`<div class="btn stroke" style="${css}">${txt}</div>`;
