# --- 1. Vorbereitung ---
# Erstellt eine leere, flexible Liste, in der wir später Laptop, Monitore und Docks speichern
$Inventory = New-Object System.Collections.Generic.List[PSObject]
# Kombiniert Domäne und Benutzername des aktuell angemeldeten Users (z.B. FIRMA\Max.Mustermann)
$User = "$env:USERDOMAIN\$env:USERNAME"

# --- 2. Netzwerk & System ---
# Holt alle physischen Netzwerkwerkkarten (ignoriert virtuelle Adapter wie VPN oder VMware)
$NetAdapters = Get-NetAdapter -Physical
# Extrahiert alle MAC-Adressen der gefundenen Karten und fügt sie mit Komma getrennt in einen Textstring zusammen
$AllMacs = ($NetAdapters | Where-Object { $_.MacAddress } | Select-Object -ExpandProperty MacAddress) -join ", "
# Ruft allgemeine Systeminfos ab (Hersteller, Modellname des PCs)
$Computer = Get-CimInstance Win32_ComputerSystem
# Ruft BIOS-Informationen ab (hauptsächlich für die Hardware-Seriennummer des Geräts)
$BIOS = Get-CimInstance Win32_Bios

# Notebook-Eintrag: Erstellt ein Objekt für den Laptop selbst und fügt es der Liste hinzu
$Inventory.Add([PSCustomObject]@{
    # Nimmt das erste Wort des Herstellers (z.B. "LENOVO" statt "Lenovo Group Ltd.") und schreibt es groß
    Anlagebezeichnung = $Computer.Manufacturer.Split(' ')[0].ToUpper()
    Modellreihe       = $Computer.Model
    Gruppe            = "NOTEBOOK"
    SERIALNUMMER      = $BIOS.SerialNumber
    Mitarbeiter       = $User
    "MAC-ADRESSE"     = $AllMacs
})

# --- 3. Monitore (Nummerierung wie in Windows-Einstellungen) ---
# Fragt die Monitor-IDs direkt aus der Windows-Verwaltungskonsole (WMI) ab; aufpassen bei ACERN Monitore, da das Ettiket von hinten nicht dem, des WMI-kodierten entspricht.
$Monitors = Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorID
$winID = 1 # Setzt einen Zähler, um die Monitore durchzunummerieren (#1, #2...)

foreach ($Mon in $Monitors) {
    # Konvertiert den Herstellercode von ASCII-Zahlen in lesbaren Text und entfernt leere Null-Zeichen
    $Mft = ([System.Text.Encoding]::ASCII.GetString($Mon.ManufacturerName) -replace "\0", "").Trim()
    # Konvertiert die Seriennummer des Monitors von ASCII in Text
    $Ser = ([System.Text.Encoding]::ASCII.GetString($Mon.SerialNumberID) -replace "\0", "").Trim()
    
    # Hersteller Mapping: Übersetzt die kryptischen 3-Buchstaben-Kürzel in Klarnamen
    if ($Mft -eq "SAM") { $Mft = "SAMSUNG" }
    elseif ($Mft -eq "LEN") { $Mft = "LENOVO" }
    elseif ($Mft -eq "ACR") { $Mft = "ACER" }
    elseif ($Mft -eq "IVM") { $Mft = "IIYAMA" }

    # Falls keine Seriennummer gefunden wird (oder "0"), markiert er ihn als "INTERN" (Laptop-Display)
    $DisplaySer = if ($Ser -eq "0" -or -not $Ser) { "[$winID] INTERN" } else { "[$winID] $Ser" }

    # Fügt jeden gefundenen Monitor einzeln der Inventar-Liste hinzu
    $Inventory.Add([PSCustomObject]@{
        Anlagebezeichnung = $Mft
        Modellreihe       = "Monitor"
        Gruppe            = "BILDSCHIRM"
        SERIALNUMMER      = $DisplaySer
        Mitarbeiter       = $User
        "MAC-ADRESSE"     = "N/A"
    })
    $winID++ # Erhöht die Nummer für den nächsten Monitor
}

# --- 4. Docking Station ---
# Filtert die Netzwerkkarten nach Begriffen wie "USB" oder "Dock" – ein starkes Indiz für eine Dockingstation
$DockAdapters = $NetAdapters | Where-Object { $_.InterfaceDescription -like "*USB*" -or $_.InterfaceDescription -like "*Dock*" }
foreach ($Dock in $DockAdapters) {
    # Fügt die Dockingstation basierend auf ihrem Netzwerkchip der Liste hinzu
    $Inventory.Add([PSCustomObject]@{
        Anlagebezeichnung = "DOCK"
        Modellreihe       = "Realtek USB Dock"
        Gruppe            = "DOCKINGSTATION"
        SERIALNUMMER      = "IDENTIFIED BY MAC" # Docks haben oft keine auslesbare Software-Seriennummer
        Mitarbeiter       = $User
        "MAC-ADRESSE"     = $Dock.MacAddress
    })
}

# --- 5. Ausgabe ---
# Gibt die gesamte Liste schön formatiert als Tabelle im PowerShell-Fenster aus
$Inventory | Format-Table Anlagebezeichnung, Modellreihe, Gruppe, SERIALNUMMER, Mitarbeiter, "MAC-ADRESSE" -AutoSize
