$password = read-host -AsSecureString

#store password as encrypted hash in abc.txt file with a key parameter as it can be run from multiple SSO ID

$encrypted_password = $password | ConvertFrom-SecureString -key (1..16) | set-content abc.txt


#retrieve the password for use in the script

$password = get-content abc.txt | ConvertTo-SecureString -key (1..16)