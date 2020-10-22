

$template = @'
{IP*:140.180.132.213} - - [{date:24/Feb/2008}:{time:00:08:59} -0600] "GET /ply/ply.html HTTP/1.1" 200 {bytes:97238}
{IP*:140.180.132.213} - - [{date:24/Feb/2008}:{time:00:08:59} -0600] "GET /favicon.ico HTTP/1.1" 404 {bytes:133}
{IP*:75.54.118.139} - - [{date:24/Feb/2008}:{time:00:15:40} -0600] "GET / HTTP/1.1" 200 {bytes:4447}
{IP*:75.54.118.139} - - [{date:24/Feb/2008}:{time:00:15:41} -0600] "GET /images/Davetubes.jpg HTTP/1.1" 200 {bytes:60025}
{IP*:122.117.168.219} - - [{date:24/Feb/2008}:{time:02:15:07} -0600] "GET /ply/ HTTP/1.1" 304 {bytes:-}
'@

$path = "D:\Tutorials\tutorial-ps\access-log"

$result = Get-Content $path | ConvertFrom-String -TemplateContent $template