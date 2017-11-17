---
external help file: UMN-Qualys-help.xml
Module Name: UMN-Qualys
online version: 
schema: 2.0.0
---

# Disconnect-Qualys

## SYNOPSIS
Disconnect Qaulys API Session, this only works on the old API

## SYNTAX

```
Disconnect-Qualys [-qualysServer] <String> [-cookie] <WebRequestSession>
```

## DESCRIPTION
Disconnect Qaulys API Session, this only works on the old API

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
disconnect-Qualys -uri 'https://qualysapi.qualys.com:443/api/2.0/fo/session/' -header (Get-QualysHeader)
```

## PARAMETERS

### -qualysServer
FQDN of qualys server, see Qualys documentation, based on wich Qualys Platform you're in.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -cookie
Use Connect-Qualys to get session cookie

```yaml
Type: WebRequestSession
Parameter Sets: (All)
Aliases: 

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES
Author: Travis Sobeck

## RELATED LINKS
