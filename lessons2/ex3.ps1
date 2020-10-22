[datetime]$date = "November 12, 2004"
$date

$t = "<servers><server name='PC1' ip='10.10.10.10'/>" +
"<server name='PC2' ip='10.10.10.12'/></servers>"
$t

[xml]$list = $t
$list.servers
$list.servers.server
$list.servers.server[0].ip = "10.10.10.11"
$list.servers.server
