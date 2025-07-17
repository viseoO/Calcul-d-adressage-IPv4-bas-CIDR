function ConvertTo-Binary {
    param ([int]$number)
    # Convertit un octet en binaire sur 8 bits
    return [Convert]::ToString($number,2).PadLeft(8,'0')
}

function Get-SubnetInfo {
    param (
        [Parameter(Mandatory=$true)][int]$CIDR,
        [string]$IPAddress = $null
    )

    if ($CIDR -lt 0 -or $CIDR -gt 32) {
        Write-Error "Le CIDR doit être entre 0 et 32."
        return
    }

    # Calcul du masque de sous-réseau en binaire (32 bits)
    $maskBits = ("1" * $CIDR).PadRight(32, "0")

    # Découpage en 4 octets
    $octets = @()
    for ($i=0; $i -lt 4; $i++) {
        $octetBinary = $maskBits.Substring($i*8,8)
        $octetDecimal = [Convert]::ToInt32($octetBinary,2)
        $octets += $octetDecimal
    }

    $maskDecimal = $octets -join "."

    # Masque binaire formaté
    $maskBinaryFormatted = ($octets | ForEach-Object { ConvertTo-Binary $_ }) -join "."

    # Calcul du nombre de bits pour les hôtes
    $hostBits = 32 - $CIDR

    # Calcul du nombre d'hôtes possibles
    if ($hostBits -le 1) {
        $hostCount = 0
    } else {
        $hostCount = [math]::Pow(2, $hostBits) - 2
    }

    Write-Output "--------------------------"
    Write-Output "Informations sur le réseau :"
    Write-Output "CIDR                   : /$CIDR"
    Write-Output "Masque décimal         : $maskDecimal"
    Write-Output "Masque binaire         : $maskBinaryFormatted"
    Write-Output "Nombre de bits hôtes   : $hostBits"
    Write-Output "Nombre d'hôtes utiles  : $hostCount"

    if ($IPAddress) {
        # Validation de l'adresse IP
        if (-not [System.Net.IPAddress]::TryParse($IPAddress, [ref]$null)) {
            Write-Error "Adresse IP invalide."
            return
        }

        $ipBytes = [System.Net.IPAddress]::Parse($IPAddress).GetAddressBytes()
        $maskBytes = $octets

        # Calcul adresse réseau (bit AND)
        $networkBytes = for ($i=0; $i -lt 4; $i++) {
            $ipBytes[$i] -band $maskBytes[$i]
        }
        $networkAddress = ($networkBytes -join ".")

        # Calcul adresse broadcast (network OR inverted mask)
        $invertedMaskBytes = for ($i=0; $i -lt 4; $i++) {
            -bnot $maskBytes[$i] -band 0xFF
        }
        $broadcastBytes = for ($i=0; $i -lt 4; $i++) {
            $networkBytes[$i] -bor $invertedMaskBytes[$i]
        }
        $broadcastAddress = ($broadcastBytes -join ".")

        # Plage d'hôtes
        function Increment-IP {
            param ([string]$ip)
            $bytes = $ip.Split(".") | ForEach-Object { [int]$_ }
            for ($i=3; $i -ge 0; $i--) {
                if ($bytes[$i] -lt 255) {
                    $bytes[$i]++
                    break
                } else {
                    $bytes[$i] = 0
                }
            }
            return ($bytes -join ".")
        }

        function Decrement-IP {
            param ([string]$ip)
            $bytes = $ip.Split(".") | ForEach-Object { [int]$_ }
            for ($i=3; $i -ge 0; $i--) {
                if ($bytes[$i] -gt 0) {
                    $bytes[$i]--
                    break
                } else {
                    $bytes[$i] = 255
                }
            }
            return ($bytes -join ".")
        }

        $firstHost = Increment-IP $networkAddress
        $lastHost = Decrement-IP $broadcastAddress

        Write-Output "Adresse réseau         : $networkAddress"
        Write-Output "Adresse broadcast      : $broadcastAddress"
        Write-Output "Plage d'hôtes          : $firstHost - $lastHost"
    }
    Write-Output "--------------------------"

}

# --- Exécution ---

$cidrInput = Read-Host "Entrez le CIDR (ex: 24 pour /24)"
$ipInput = Read-Host "Entrez une adresse IP réseau (optionnel, ou laissez vide)"

# Convertir en entier ici
try {
    $cidrInt = [int]$cidrInput
} catch {
    Write-Error "Le CIDR doit être un nombre entier valide."
    exit
}

if ([string]::IsNullOrWhiteSpace($ipInput)) {
    Get-SubnetInfo -CIDR $cidrInt
} else {
    Get-SubnetInfo -CIDR $cidrInt -IPAddress $ipInput
}
