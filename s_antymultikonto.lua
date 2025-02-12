local BazaDanychSQL = exports.oxmysql
local tokenik = "TOKEN BOTA"
local RolaPozwolMulciakiID = "ID ROLI KTORA MOZE MIEC MULCIAKI np. .AllowMulciaki"
local GuildID = "ID DISCORDA (serwera)"

local function sprawdzCzyMaRoleDiscord(discordID, roleID, callback)
    local endpoint = ("https://discord.com/api/v10/guilds/%s/members/%s"):format(GuildID, discordID:gsub("discord:", ""))
    
    local headers = {
        ["Authorization"] = "Bot " .. tokenik,
        ["Content-Type"] = "application/json"
    }

    PerformHttpRequest(endpoint, function(statusCode, responseText, headers)
        if statusCode == 200 then
            local data = json.decode(responseText)
            if not data then
                callback(false)
                return
            end

            if data.roles then
                for _, role in ipairs(data.roles) do
                    if role == roleID then
                        callback(true)
                        return
                    end
                end
                callback(false)
            else
                callback(false)
            end
        else
            callback(false)
        end
    end, "GET", "", headers)
end


local function sprawdzDaneWBazie(discord, license, steam, callback)
    local wynik = BazaDanychSQL:querySync("SELECT * FROM skowix_antymulciak WHERE discord = ? OR license = ? OR steam = ?", {discord, license, steam})
    
    if #wynik > 0 then
        callback(true, wynik)
    else
        callback(false)
    end
end

local function dodajDaneDoBazy(discord, license, steam)
    BazaDanychSQL:insert("INSERT INTO skowix_antymulciak (discord, license, steam) VALUES (?, ?, ?)", {discord, license, steam})
end

AddEventHandler('playerConnecting', function(playerName, setKickReason, deferrals)
    local src = source
    deferrals.defer()
    
    Citizen.Wait(0)
    deferrals.update("Sprawdzanie Twoich danych...")

    local identifiers = GetPlayerIdentifiers(src)
    local discord, license, steam = nil, nil, nil

    for _, identifier in ipairs(identifiers) do
        if string.find(identifier, "discord:") then
            discord = identifier
        elseif string.find(identifier, "license:") then
            license = identifier
        elseif string.find(identifier, "steam:") then
            steam = identifier
        end
    end

    if not discord or not license or not steam then
        deferrals.done("[SYSTEM AntyMulciak] Nie wykryto wymaganego identyfikatora (Discord, Licencja Rockstar lub steam).")
        return
    end

    sprawdzDaneWBazie(discord, license, steam, function(czyIstniejeWBazie, dane)
        if czyIstniejeWBazie then
            local graczDane = dane[1]
            if graczDane.license ~= license or graczDane.steam ~= steam then
                deferrals.update("Sprawdzanie Twojej rangi na Discordzie...")
                sprawdzCzyMaRoleDiscord(discord, RolaPozwolMulciakiID, function(MaBypassaRolaDC)
                    if MaBypassaRolaDC then
                        deferrals.done()
                    else
                        deferrals.done("\n\n[SYSTEM] Wykryto multikonto. Nie możesz dołączyć na serwer.\n Jeżeli uważasz że to błąd to Ticket Zarząd.")
                    end
                end)
            else
                deferrals.done()
            end
        else
            dodajDaneDoBazy(discord, license, steam)
            deferrals.done()
        end
    end)
end)
