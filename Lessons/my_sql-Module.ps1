$server="localhost"
$username="root"
$password=""
#create database
$database="trainings"
[void][system.reflection.Assembly]::LoadFrom('C:\Program Files (x86)\MySQL\MySQL Connector Net 6.9.7\Assemblies\v4.5\MySql.Data.dll')
function global:Set-SqlConnection ( $server = $(Read-Host "SQL Server Name"), $username = $(Read-Host "Username"), $password = $(Read-Host "Password"), $database = $(Read-Host "Default Database") )
{
$SqlConnection.ConnectionString = "server=$server;
user id=$username;
password=$password;
database=$database;
pooling=false;
Allow Zero Datetime=True;"
}
function global:Get-SqlDataTable( $Query = $(if (-not ($Query -gt $null)) {Read-Host "Query to run"}) )
{
if (-not ($SqlConnection.State -like "Open")) { $SqlConnection.Open() }
$SqlCmd = New-Object MySql.Data.MySqlClient.MySqlCommand $Query, $SqlConnection
$SqlAdapter = New-Object MySql.Data.MySqlClient.MySqlDataAdapter
$SqlAdapter.SelectCommand = $SqlCmd
$DataSet = New-Object System.Data.DataSet
$SqlAdapter.Fill($DataSet) | Out-Null
$SqlConnection.Close()
return $DataSet.Tables[0]
}
Set-Variable SqlConnection (New-Object MySql.Data.MySqlClient.MySqlConnection) -Scope Global -Option AllScope -Description "Personal variable for Sql Query functions"
Set-SqlConnection $server $username $password $database
$mysqltest = Get-SqlDataTable 'SHOW STATUS'
