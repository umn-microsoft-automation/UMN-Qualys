$header = Get-QualysHeader
$uri = 'https://qualysapi.qualys.com:443/api/2.0/fo/'
$cookie = Connect-Qualys -uri $uri -header $header -qualysCred (Get-Credential)

$data = Get-QualysReportList -uri $uri -header $header -cookie $cookie
$data
$data | select ID,TITLE,TYPE

get-QualysReport -uri $uri -header $header -cookie $cookie -id 14861818 -outFilePath C:\Users\oittjsobeck\Desktop\
Get-QualysAssetGrp -uri $uri -header $header -cookie $cookie

Get-QualysAssetGrp -uri $uri -header $header -cookie $cookie -id '1919036'


