$from ='texas'
$to ='new york'
$Mode = 'driving'
$Units='imperial'

$key = 'AIzaSyCaDCk5B2rUB3tNlQHVyfOVh9mkxCp3aVM'

$webpage = Invoke-WebRequest "https://maps.googleapis.com/maps/api/distancematrix/json?origins=$From&destinations=$To&mode=$($Mode.toLower())&units=$Units&key=$key" -UseBasicParsing -ErrorVariable EV

$content = $webpage.Content | ConvertFrom-Json
$Results = $content.rows