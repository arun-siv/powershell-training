$book_array = @("foo","bar")

$hash1 = [ordered]@{

    Height = 10;
    width = 20;
    length = 10;
    volume = 2000;
    books = $book_array

}


$hash2 = [ordered]@{

    Height = 5;
    width = 2;
    length = 5;
    volume = $_.Height * $_.length * $_.width;
    books = $book_array

}


     $myobj = New-Object PSObject -Property @{
            Height = $_.President;
            TookOffice = $_.TookOffice;
            LeftOffice = $_.LeftOffice
        }
        
$obj = [pscustomobject]$hash1 
$obj | Add-Member -NotePropertyName "Weight" -TypeName obj 
 Add-Member -InputObject $obj -MemberType ScriptMethod -Name  "Vol" -value  {$this.Height * $this.width * $this.length} -PassThru
 $getblock = { return $this.Country; }
 Add-Member -InputObject $obj -MemberType ScriptProperty -name "VVV" -Value $getblock -SecondValue {$this.Height * $this.width * $this.length} -PassThru

 Add-Member -InputObject $obj -MemberType NoteProperty -Name 'v' -Value {$this.Height * $this.width * $this.length} -PassThru


$a = New-Object -TypeName 'System.Management.Automation.PSObject' -Property @{ ID=1; Country='US' };
$setCounrtyBlock = {
    param ([string] $cntry)
    $this.Country = $cntry;
};
Add-Member -InputObject $a -MemberType ScriptMethod -Name 'SetCountry' -Value $setCounrtyBlock;


$a.Country;
$a.SetCountry('UK');
$a.Country;