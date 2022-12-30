param ($keyVaultName, $keyName)

$accessKey = $(az keyvault secret show --name $keyName --vault-name $keyVaultName --query value -o tsv)
$Env:TF_ARM_ACCESS_KEY = $accessKey