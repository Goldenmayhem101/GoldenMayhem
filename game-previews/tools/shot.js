const {chromium}=require('playwright');const {spawn}=require('child_process');
const ids=process.argv.slice(2);
(async()=>{const srv=spawn('python3',['-m','http.server','8770'],{cwd:'/home/claude/gp',stdio:'ignore'});await new Promise(r=>setTimeout(r,800));
const b=await chromium.launch({args:['--use-gl=angle','--use-angle=swiftshader','--enable-unsafe-swiftshader','--ignore-gpu-blocklist']});
for(const id of ids){const pg=await b.newPage({viewport:{width:540,height:960},deviceScaleFactor:2});
pg.on('pageerror',e=>console.log(id,'pageerr',e.message));
await pg.goto('http://localhost:8770/page.html?s='+id);
try{await pg.waitForFunction('window.__done',null,{timeout:120000});}catch(e){console.log(id,'TIMEOUT');}
const er=await pg.evaluate('window.__err');if(er)console.log(id,'ERR',er.slice(0,400));
await pg.waitForTimeout(300);await pg.screenshot({path:'/home/claude/gp/out/'+id+'.png'});console.log('shot',id);await pg.close();}
await b.close();srv.kill()})();
