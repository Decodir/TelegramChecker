require('addon')
local sampev = require 'libs.samp.events'
local json = require("dkjson")
local lfs = require("lfs")
local effil = require 'effil'
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8

-------------------------------------------JSON-------------------------------------------
-- Путь к JSON файлу
local filePath = "CheckerList.json"
-- Проверяем, существует ли файл
local fileExists = lfs.attributes(filePath, "mode") == "file"
-- Если файл не существует, создаем его
if not fileExists then
    local file = io.open(filePath, "w")
    file:write('{"token":["none"], "chatid":["0"], "nicknames":[]}')
    file:close()
end
-- Считываем содержимое JSON файла
local file = io.open(filePath, "r")
local jsonContent = file:read("*a")
file:close()
-- Преобразуем JSON содержимое в таблицу
local data = json.decode(jsonContent)
local function formateJson()
    -- Преобразуем таблицу обратно в JSON формат
    local updatedJsonContent = json.encode(data)
    -- Записываем обновленное содержимое в JSON файл
    file = io.open(filePath, "w")
    file:write(updatedJsonContent)
    file:close()
end

local function getPlayerNicknamesAsString()
    local nicknames = ""
    local nicknameCount = 0
    local file = io.open(filePath, "r")
    local contents = file:read("*a")
    file:close()
    local dataNick = json.decode(contents)['nicknames']
    for id, player in pairs(getAllPlayers()) do
        for k, v in ipairs(dataNick) do
            if player.nick == v then
                nicknameCount = nicknameCount + 1
                nicknames = nicknames .. '\n'.. player.nick .. '['..id..']'
            end
        end
    end
    return nicknames, nicknameCount
end

local function addNicknames(nicknamesToAdd)
    -- Проверка на наличие дубликатов ников
    local duplicates = {}
    for _, nickname in ipairs(nicknamesToAdd) do
        if not duplicates[nickname] then
            duplicates[nickname] = true
            -- Проверка наличия никнейма в списке
            local found = false
            for _, existingNickname in ipairs(data.nicknames) do
                if existingNickname == nickname then
                    found = true
                    break
                end
            end
            if not found then
                table.insert(data.nicknames, nickname)
                sendTG('%E2%9C%85 Ник "'..nickname..'" добавлен в чекер.')
            else
                sendTG('%E2%9A%A0 Ник "' .. nickname .. '" уже существует в списке.')
            end
        else
            sendTG('%E2%9A%A0 Ник "' .. nickname .. '" уже существует в списке.')
        end
    end
    formateJson()
end

-- Функция для удаления ников
local function removeNicknames(nicknamesToRemove)
    for _, nickname in ipairs(nicknamesToRemove) do
        -- Проверка наличия никнейма в списке
        local found = false
        for i, storedNickname in ipairs(data.nicknames) do
            if storedNickname == nickname then
                found = true
                table.remove(data.nicknames, i)
                sendTG('%E2%9C%85 Ник "'..nickname..'" убран из чекера.')
                break
            end
        end
        if not found then
            sendTG('%E2%9A%A0 Ник "' .. nickname .. '" не найден в списке.')
        end
    end
    formateJson()
end
----------------------------------------SHITCODE----------------------------------------

local function countOffList()
    local offfile = io.open(filePath, "r")
    local offcontent = offfile:read("*a")
    offfile:close()
    local decodedTable = json.decode(offcontent)
    local count = #decodedTable.nicknames
    local nicknames = ""
    for _, nickname in pairs(decodedTable.nicknames) do
        nicknames = nicknames .. '\n' .. nickname
    end
    return count, nicknames
end

local function modifyJsonFile(key, value)
    -- Чтение файла JSON
    local file = io.open(filePath, "r")
    local content = file:read("*a")
    file:close()
    -- Распарсить JSON содержимое
    local data = json.decode(content)

    -- Добавить или заменить значение
    data[key] = value

    -- Преобразовать данные обратно в JSON строку
    local updatedContent = json.encode(data)

    -- Записать обновленное содержимое обратно в файл
    local updatedFile = io.open(filePath, "w")
    updatedFile:write(updatedContent)
    updatedFile:close()
end

local function returnTelegram()
    -- Чтение файла JSON
    local file = io.open(filePath, "r")
    local content = file:read("*a")
    file:close()

    -- Распарсить JSON содержимое
    local data = json.decode(content)

    -- Преобразовать значение токена и chatid в строки
    local token = tostring(data.token)
    local chatid = tostring(data.chatid)

    -- Вернуть таблицу с токеном и chatid
    return {
        token = token,
        chatid = chatid
    }
end

-----------------------------------------NOTF&TG-----------------------------------------
local ansi_decode = {[128] = '\208\130',[129] = '\208\131',[130] = '\226\128\154',[131] = '\209\147',[132] = '\226\128\158',[133] = '\226\128\166',[134] = '\226\128\160',[135] = '\226\128\161',[136] = '\226\130\172',[137] = '\226\128\176',[138] = '\208\137',[139] = '\226\128\185',[140] = '\208\138',[141] = '\208\140',[142] = '\208\139',[143] = '\208\143',[144] = '\209\146',[145] = '\226\128\152',[146] = '\226\128\153',[147] = '\226\128\156',[148] = '\226\128\157',[149] = '\226\128\162',[150] = '\226\128\147',[151] = '\226\128\148',[152] = '\194\152',[153] = '\226\132\162',[154] = '\209\153',[155] = '\226\128\186',[156] = '\209\154',[157] = '\209\156',[158] = '\209\155',[159] = '\209\159',[160] = '\194\160',[161] = '\209\142',[162] = '\209\158',[163] = '\208\136',[164] = '\194\164',[165] = '\210\144',[166] = '\194\166',[167] = '\194\167',[168] = '\208\129',[169] = '\194\169',[170] = '\208\132',[171] = '\194\171',[172] = '\194\172',[173] = '\194\173',[174] = '\194\174',[175] = '\208\135',[176] = '\194\176',[177] = '\194\177',[178] = '\208\134',[179] = '\209\150',[180] = '\210\145',[181] = '\194\181',[182] = '\194\182',[183] = '\194\183',[184] = '\209\145',[185] = '\226\132\150',[186] = '\209\148',[187] = '\194\187',[188] = '\209\152',[189] = '\208\133',[190] = '\209\149',[191] = '\209\151'}
function AnsiToUtf8(s)
    local r, b = '', ''
    for i = 1, s and s:len() or 0 do
        b = s:byte(i)
        if b < 128 then
            r = r .. string.char(b)
        else
            if b > 239 then
                r = r .. '\209' .. string.char(b - 112)
            elseif b > 191 then
                r = r .. '\208' .. string.char(b - 48)
            elseif ansi_decode[b] then
                r = r .. ansi_decode[b]
            else
                r = r .. '_'
            end
        end
    end
    return r
end

function threadHandle(runner, url, args, resolve, reject)
    local t = runner(url, args)
    local r = t:get(0)
    while not r do
        r = t:get(0)
        wait(0)
    end
    local status = t:status()
    if status == 'completed' then
        local ok, result = r[1], r[2]
        if ok then
            resolve(result)
        else
            reject(result)
        end
    elseif err then
        reject(err)
    elseif status == 'canceled' then
        reject(status)
    end
    t:cancel(0)
end

function requestRunner()
    return effil.thread(function(u, a)
        local https = require 'ssl.https'
        local ok, result = pcall(https.request, u, a)
        if ok then
            return {true, result}
        else
            return {false, result}
        end
    end)
end

function async_http_request(url, args, resolve, reject)
    local runner = requestRunner()
    if not reject then
        reject = function()
        end
    end
    newTask(function()
        threadHandle(runner, url, args, resolve, reject)
    end)
end

function encodeUrl(str)
    str = str:gsub(' ', '%+')
    str = str:gsub('\n', '%%0A')
    return u8:encode(str, 'CP1251')
end

function sendTG(msg)
    msg = msg:gsub('{......}', '')
    msg = encodeUrl(msg)
    async_http_request('https://api.telegram.org/bot' .. returnTelegram().token .. '/sendMessage?chat_id=' .. returnTelegram().chatid .. '&text=' .. msg,
        '', function(result)
        end)
end

function get_telegram_updates()
    newTask(function()
        while not updateid do
            wait(1)
        end
        local runner = requestRunner()
        local reject = function()
        end
        local args = ''
        while true do
            url = 'https://api.telegram.org/bot' .. returnTelegram().token .. '/getUpdates?chat_id=' .. returnTelegram().chatid .. '&offset=-1'
            threadHandle(runner, url, args, processing_telegram_messages, reject)
            wait(0)
        end
    end)
end

function processing_telegram_messages(result)
    if result then
        local proc_table = json.decode(result)
        if proc_table.ok then
            if #proc_table.result > 0 then
                local res_table = proc_table.result[1]
                if res_table then
                    if res_table.update_id ~= updateid then
                        updateid = res_table.update_id
                        local message_from_user = res_table.message.text
                        if message_from_user then
                            local text = u8:decode(message_from_user)
                            print("Получена команда: "..text)
                            if text:find('^!add(.-)') then
                                if text:find('^!add%s*(%w+_%w+)$') then
                                    local tgnick = text:match('^!add%s*(%w+_%w+)$')
                                    addNicknames({tgnick})

                                elseif text:find('^!add%s*(%w+)$') then
                                    local tgnick = text:match('^!add%s*(%w+)$')
                                    addNicknames({tgnick})

                                else sendTG('%E2%9A%A0 Ник написан не по форме\nПравильный пример: !add cord/Cord/Cord_Lua') end
                            elseif text:find('^!dell(.-)') then
                                if text:find('^!dell%s*(%w+_%w+)$') then
                                    local tgnick = text:match('^!dell%s*(%w+_%w+)$')
                                    removeNicknames({tgnick})

                                elseif text:find('^!dell%s*(%w+)$') then
                                    local tgnick = text:match('^!dell%s*(%w+)$')
                                    removeNicknames({tgnick})

                                else sendTG('%E2%9A%A0 Ник написан не по форме\nПравильный пример: !dell cord/Cord/Cord_Lua') end
                            elseif text:find('^!onlist$') then
                                local nicknames, nicknameCount = getPlayerNicknamesAsString()
                                if nicknames == '' then
                                    sendTG('%E2%9A%A0 Никого нет на сервере')
                                else
                                    sendTG('%E2%AD%90 Игроки онлайн['..nicknameCount..']: '..nicknames)
                                end
                            elseif text:find('^!offlist$') then
                                local count, nicknames = countOffList()
                                sendTG('%F0%9F%91%BB Ники в чекере['..count..']: '..nicknames)
                            elseif text:find('^!cmds$') then
                                sendTG('%E2%AD%90 Все команды:\n!add *nick* --добавить ник в чекер\n!dell *nick* -- удалить ник из чекера\n!onlist -- просмотр ников в сети\n!offlist -- просмотр всех ников в чекере')
                            else
                                sendTG('%E2%9A%A0 Введенной команды не существует\nВведите !cmds для просмотра всех команд.')
                            end
                        end
                    end
                end
            end
        end
    end
end

function getLastUpdate()
    async_http_request('https://api.telegram.org/bot' .. returnTelegram().token .. '/getUpdates?chat_id=' .. returnTelegram().chatid .. '&offset=-1', '',
        function(result)
            if result then
                local proc_table = json.decode(result)
                if proc_table.ok then
                    if #proc_table.result > 0 then
                        local res_table = proc_table.result[1]
                        if res_table then
                            updateid = res_table.update_id
                        end
                    else
                        updateid = 1
                    end
                end
            end
        end)
end

-------------------------------------------MAIN-------------------------------------------

function onLoad()
    getLastUpdate()
    get_telegram_updates()
    sendTG('Версия: 1.1\nАвтор: @cordhere\nОфициальная тема: https://www.blast.hk/threads/180478/')
end

function onRunCommand(cmd)
    if cmd:find('^!token%s*(.-)$') then
        local token_json = cmd:match('^!token%s*(.-)$')
        modifyJsonFile("token", token_json)
        print("token обновлен.")
        return false
    elseif cmd:find('^!chatid%s*(.-)$') then
        local chatid_json = cmd:match('^!chatid%s*(.-)$')
        modifyJsonFile("chatid", chatid_json)
        print("chatid обновлен.")
        return false
    end
end

function sampev.onPlayerJoin(playerId, color, isNpc, playername)
    local file = io.open(filePath, "r")
    local jsonContent = file:read("*a")
    file:close()
    local data = json.decode(jsonContent)
    for _, lol in pairs(data.nicknames) do
        if lol:find('^' .. playername..'$') then
            sendTG('%E2%9C%85 Ник "'..playername..'" обнаружен на сервере.')
        end
    end
end

function sampev.onPlayerQuit(playerQuitId, reason)
    local file = io.open(filePath, "r")
    local jsonContent = file:read("*a")
    file:close()
    local data = json.decode(jsonContent)
    for _, lol in pairs(data.nicknames) do
        if lol:find('^' .. getAllPlayers()[playerQuitId].nick..'$') then
            sendTG('%F0%9F%9A%A7 Ник "'..getAllPlayers()[playerQuitId].nick..'" покинул сервер.')
        end
    end
end






--[[

    addNicknames({"FASTER", "ALE???"})
    removeNicknames({"NEW"})
    sendTG("asd")
    
]]
