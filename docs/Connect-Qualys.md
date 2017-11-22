---
external help file: UMN-Qualys-help.xml
Module Name: UMN-Qualys
online version: 
schema: 2.0.0
---

# Connect-Qualys

## SYNOPSIS
Connect to Qualys API and get back session $cookie for all other functions

## SYNTAX

```
Connect-Qualys [-qualysCred] <PSCredential> [-qualysServer] <String> [-assetTagging]
```

## DESCRIPTION
Connect to Qualys API and get back session $cookie for all other functions.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
$cookie = Connect-Qualys -qualysCred $qualysCred -qualysServer $qualysServer
```

### -------------------------- EXAMPLE 2 --------------------------
```
$cookie = Connect-Qualys -qualysCred $qualysCred -qualysServer $qualysServer -assetTagging
```

## PARAMETERS

### -qualysCred
use Get-Credential to create a PSCredential with the username and password of an account that has access to Qualys

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases: 

Required: True
Position: 1
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
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -assetTagging
There are two different api endpoints, the new one is Asset Management and Tagging. 
Use this switch to get a cookie to make calls to Asset Management and Tagging

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES
Author: Travis Sobeck, Kyle Weeks

## RELATED LINKS

