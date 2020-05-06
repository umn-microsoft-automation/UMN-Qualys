---
external help file: UMN-Qualys-help.xml
Module Name: UMN-Qualys
online version:
schema: 2.0.0
---

# Update-QualysIP

## SYNOPSIS
Update IP asset in Qualys.

## SYNTAX

```
Update-QualysIP [-cookie] <WebRequestSession> [[-ip] <String>] [-fqdn] <String> [-qualysServer] <String>
 [<CommonParameters>]
```

## DESCRIPTION
Update the FQDN, NetBIOS, and IP tracking info of the asset.

## EXAMPLES

### EXAMPLE 1
```
Update-QualysIP -cookie $cookie -ip $ip -fqdn $fqdn -qualysServer $qualysServer
```

## PARAMETERS

### -cookie
Use Connect-Qualys to get session cookie

```yaml
Type: WebRequestSession
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ip
Valid IP address asset to be updated

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -fqdn
Domain validated and tested FQDN of host.
something.ad.umn.edu

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -qualysServer
FQDN of qualys server, see Qualys documentation, based on wich Qualys Platform you're in.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Authors: Kyle Weeks

## RELATED LINKS
