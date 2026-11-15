import base64,re,pathlib
f=pathlib.Path('/home/claude/gmkit/fonts');b=lambda n:base64.b64encode((f/n).read_bytes()).decode()
s=open('/home/claude/linkscribe/app_page.html').read()
s=re.sub(r'<link[^>]*fonts\.(?:googleapis|gstatic)[^>]*>\n?','',s)
s=s.replace("--head:'Bricolage Grotesque',system-ui,sans-serif; --body:'IBM Plex Sans',system-ui,sans-serif; --mono:'IBM Plex Mono',ui-monospace,monospace;","--head:'Baloo 2',system-ui,sans-serif; --body:'Nunito',system-ui,sans-serif; --mono:ui-monospace,'Roboto Mono','SFMono-Regular',Menlo,Consolas,monospace;")
css=("@font-face{font-family:'Baloo 2';src:url(data:font/woff;base64,%s) format('woff');font-weight:400 800;font-display:block}"
     "@font-face{font-family:'Nunito';src:url(data:font/woff;base64,%s) format('woff');font-weight:200 1000;font-display:block}")%(b('baloo2.woff'),b('nunito.woff'))
s=s.replace('</head>','<style>'+css+'</style></head>',1)
assert 'Bricolage' not in s.split('<style>')[0]
open('/home/claude/linkscribe/app_final.html','w').write(s);print(len(s)//1024,'KB')
