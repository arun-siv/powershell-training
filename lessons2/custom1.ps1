$book_array = @("foo","bar" ,"car")

$hash1 = [ordered]@{

    Height = 10;
    width = 20;
    length = 10;

    books = $book_array

}
$obj = [pscustomobject]$hash1
$hash1.Remove('volume')

Add-Member -InputObject $obj -MemberType NoteProperty -name 'Volume' -Value 0 

$getblock = { return $this.Volume; }

$setblock = { return  $this.Volume = $this.Height * $this.Width * $this.length }

Add-Member -InputObject $obj -MemberType ScriptProperty -Name 'TotalVol' -Value $getblock -SecondValue $setblock

function create-Country([int]$id , [string]$country )  {


$obj = New-Object psobject -Property @{
 ID = $id; 
 Country = $country
 }

 $setCounrtyBlock = {

        $this.Country = $country;
    };
    Add-Member -InputObject $obj -MemberType ScriptMethod -Name 'SetCountry' -Value $setCounrtyBlock;
    return $obj;

}

