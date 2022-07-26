ESX = nil
TriggerEvent('esx:getSharedObject', function(obj)
    ESX = obj
end)

RegisterServerEvent('chat:init')
RegisterServerEvent('chat:addTemplate')
RegisterServerEvent('chat:addMessage')
RegisterServerEvent('chat:addSuggestion')
RegisterServerEvent('chat:removeSuggestion')
RegisterServerEvent('_chat:messageEntered')
RegisterServerEvent('chat:clear')
RegisterServerEvent('__cfx_internal:commandFallback')

AddEventHandler('_chat:messageEntered', function(author, color, message, group)
    local _source = source
    if not message or not author then
        return
    end
	local time = os.date("%X %p")
    
    --TriggerEvent('chatMessage', author, message)

    if not WasEventCanceled() and group == 'all' then
        
		TriggerClientEvent('chat:addMessage', -1, { template = '<div style="padding: 0.1vw; margin: 0.1vw; font-weight:bold; font-size:16px;">[{0}] <span style="color:rgb(106, 184, 251); word-break: break-all;">{1} </span"> ^0: {2} </div>', multiline = true, args = { time, author, message} })
        
        print('[all] '..author .. '^7: ' .. message .. '^7')

    elseif not WasEventCanceled() and group == 'guild' then
        --todo send message to same guild
        local xPlayer = ESX.GetPlayerFromId(_source)
        local targetGuild = xPlayer.get("guild")
        local xTargets = ESX.GetPlayers()
        for i=1, #xTargets do
            local xTarget = ESX.GetPlayerFromId(xTargets[i])
            if xTarget.get("guild") == targetGuild then
                TriggerClientEvent('chat:addMessage', xTargets[i], { template = '<div style="padding: 0.1vw; margin: 0.1vw; font-weight:bold; font-size:16px;">[{0}] <span style="color:rgb(106, 184, 251); word-break: break-all;">{1} </span"> ^0: {2} </div>', multiline = true, args = { time, author, message} })
            end
        end

        print('[guild] - '..targetGuild..' '..author .. '^7: ' .. message .. '^7')
    else
		TriggerClientEvent('chat:addMessage', _source, {args = {"Error group -請截圖通知管理員"}, multiline = true, color = {255,0,0} })
	end

    
end)

AddEventHandler('__cfx_internal:commandFallback', function(command)
    local name = GetPlayerName(source)
	local time = os.date("%X %p")
	
    TriggerEvent('chatMessage', source, name, '/' .. command)
	
	if not WasEventCanceled() then
	
		TriggerClientEvent('chat:addMessage', -1, { template = '<div style="padding: 0.1vw; margin: 0.1vw; font-weight:bold; font-size:16px;">[{0}] <span style="color:rgb(106, 184, 251); word-break: break-all;">{1} </span"> ^0: /{2} </div>', multiline = true, args = { time, name, command} })
	
	end
   
	CancelEvent()
end)

-- command suggestions for clients
local function refreshCommands(player)
    if GetRegisteredCommands then
        local registeredCommands = GetRegisteredCommands()

        local suggestions = {}

        for _, command in ipairs(registeredCommands) do
            if IsPlayerAceAllowed(player, ('command.%s'):format(command.name)) then
                table.insert(suggestions, {
                    name = '/' .. command.name,
                    help = ''
                })
            end
        end

        TriggerClientEvent('chat:addSuggestions', player, suggestions)
    end
end

AddEventHandler('chat:init', function()
    refreshCommands(source)
end)

AddEventHandler('onServerResourceStart', function(resName)
    Wait(500)

    for _, player in ipairs(GetPlayers()) do
        refreshCommands(player)
    end
end)
