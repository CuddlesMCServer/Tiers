local Tiers = lukkit.addPlugin("Tiers", "v1.0-beta",
    function(plugin)
        
        plugin.onEnable(
            function()
                -- Prints to the console that the plugin has enabled this version
                plugin.print("Enabled "..plugin.version )
                
                -- Create the default config file
                plugin.config.setDefault("config.slots", 3)
                
                -- Enable certain tier sets
                plugin.config.set("config.unranked.enable", true)
                plugin.config.setDefault("config.tier1.enable", true)
                plugin.config.setDefault("config.tier2.enable", false)
                plugin.config.setDefault("config.tier3.enable", false)
                plugin.config.setDefault("config.tier4.enable", false)
                
                -- These are the names of each rank
                plugin.config.setDefault("config.unranked.name", "Default")
                plugin.config.setDefault("config.tier1.name", "Tier1")
                plugin.config.setDefault("config.tier2.name", "Tier2")
                plugin.config.setDefault("config.tier3.name", "Tier3")
                plugin.config.setDefault("config.tier4.name", "Tier4")
                
                -- Defines the default theme for the interface
                plugin.config.setDefault("config.theme", "seasonal")
                -- This wont mess anything up, but includes hidden (or not so hidden) features
                plugin.config.setDefault("config.eastereggs", true)
                plugin.config.save()
                
                -- Create the theme table depending on what theme is chosen.
                if plugin.config.get("config.theme") == "red" then
                    t = { "§4", "§c", "§f" }
                elseif plugin.config.get("config.theme") == "blue" then
                    t = { "§9", "§b", "§f" }
                elseif plugin.config.get("config.theme") == "green" then
                    t = { "§2", "§a", "§f" }
                elseif plugin.config.get("config.theme") == "yellow" then
                    t = { "§6", "§e", "§f" }
                elseif plugin.config.get("config.theme") == "purple" then
                    t = { "§5", "§d", "§f" }
                elseif plugin.config.get("config.theme") == "seasonal" then
                    local m = tonumber( os.date("%m") )
                    local md = os.date("%m-%d")
                    
                    if md == "01-04" and plugin.config.get("config.eastereggs") == true then
                        t = { "§0", "§8", "§7" }
                        plugin.print("April Fools!")
                    elseif md == "25-12" and plugin.config.get("config.eastereggs") == true then
                        t = { "§2", "§c", "§a" }
                        plugin.print("Merry Christmas!")
                    elseif md == "01-08" and plugin.config.get("config.eastereggs") == true then
                        t = { "§3", "§2", "§6" }
                        plugin.print("It is Lord_Cuddles' birthday today!")
                    elseif md == "09-05" and plugin.config.get("config.eastereggs") == true then
                        t = { "§8", "§3", "§d" }
                        plugin.print("It is PineLily's birthday today!")
                    elseif m >= 1 and m < 4 then
                        t = { "§9", "§b", "§f" }
                        plugin.print("Using seasonal Winter theme!")
                    elseif m >= 4 and m < 7 then
                        t = { "§2", "§a", "§f" }
                        plugin.print("Using seasonal Spring theme!")
                    elseif m >= 7 and m < 10 then
                        t = { "§6", "§e", "§f" }
                        plugin.print("Using seasonal Summer theme!")
                    elseif m >= 10 then
                        t = { "§4", "§c", "§f" }
                        plugin.print("Using seasonal Autumn theme!")
                    else
                        t = { "§8", "§7", "§f" }
                        plugin.warn("Whoops, this shouldnt have happened! Report this bug, with the time and date shown.")
                    end
                else
                    plugin.config.set("config.theme", "silver")
                    plugin.config.save()
                    t = { "§8", "§7", "§f" }
                end
                plugin.print("Using theme: "..plugin.config.get("config.theme"))
                
            end
        )
        
        plugin.onDisable(
            function()
                plugin.warn("Caution! Disabled")
            end
        )
        
        function saveset( uuid, id, set )
            if set.exists then plugin.config.set( uuid.."."..id..".exists", set.exists ) end
            if set.tier then plugin.config.set( uuid.."."..id..".tier", set.tier ) end
            if set.slots then plugin.config.set( uuid.."."..id..".slots", set.slots )
                if type(set.slotn) == "table" and type(set.slotu) == "table" then
                    for i = 1, #set.slotn do
                        if set.slotn[i] then
                            plugin.config.set(uuid.."."..id..".slot."..i..".name", set.slotn[i])
                            plugin.config.set(uuid.."."..id..".slot."..i..".uuid", set.slotu[i])
                        else
                            plugin.config.clear(uuid.."."..id..".slot."..i..".name")
                            plugin.config.clear(uuid.."."..id..".slot."..i..".uuid")
                        end
                    end
                end
            end
            plugin.config.save()
        end
        
        function loadset( uuid, id )
            local set = {}
            if plugin.config.get( uuid .. "." .. id .. ".exists") then set.exists = plugin.config.get( uuid .. "." .. id .. ".exists") end
            if plugin.config.get( uuid .. "." .. id .. ".tier" ) then set.tier = plugin.config.get( uuid .. "." .. id .. ".tier" ) end
            if plugin.config.get( uuid .. "." .. id .. ".slots" ) then set.slots = plugin.config.get( uuid .. "." .. id .. ".slots" )
                set.slotn = {}
                set.slotu = {}
                for i = 1, set.slots do
                    if plugin.config.get( uuid .. "." .. id .. ".slot." .. i .. ".name" ) then 
                        set.slotn[i] = plugin.config.get( uuid .. "." .. id .. ".slot." .. i .. ".name" )
                    end
                    if plugin.config.get( uuid .. "." .. id .. ".slot." .. i .. ".uuid" ) then
                        set.slotu[i] = plugin.config.get( uuid .. "." .. id .. ".slot." .. i .. ".uuid" )
                    end
                end
            end
            return set
        end
        
        plugin.addCommand("tier", "Manage owned tier sets and slots", "/tier help",
            function(sender, args)
                if args[1] == "list" then
                    if not args[2] then args[2] = sender:getName() end
                    local offline = server:getOfflinePlayer(args[2])
                    local uuid = offline:getUniqueId():toString()
                    local name = offline:getName()
                    local sets = tonumber( plugin.config.get( uuid..".sets"))
                    sender:sendMessage(t[1].."==========[ "..t[2]..name..t[1].." - "..t[2].."Set List"..t[1].." ]==========")
                    if not sets then sets = 0 end
                    if sets > 0 then
                        local count = 0
                        for st = 1, sets do
                            local set = loadset( uuid, st )
                            if set.exists == true then
                                sender:sendMessage(t[1].."["..t[2].."Set ID #"..st..t[1].."] "..t[3].."Tier "..set.tier.." with "..#set.slotn.."/"..set.slots.." slot occupied")
                                count = count + 1
                            end
                        end
                        if count == 0 then
                            sender:sendMessage(t[2].."No sets found. Contact Lord_Cuddles if this is in error.")
                        end
                    else
                        sender:sendMessage(t[2].."No sets found. Contact Lord_Cuddles if this is in error.")
                    end
                elseif args[1] == "info" then
                    if args[2] then
                        args[2] = tonumber(args[2])
                        if not args[2] then args[2] = 1 end
                        if args[2] > 0 then
                            if not args[3] then args[3] = sender:getName() end
                            local offline = server:getOfflinePlayer(args[3])
                            local uuid = offline:getUniqueId():toString()
                            local name = offline:getName()
                            local set = loadset( uuid, args[2] )
                            sender:sendMessage(t[1].."==========[ "..t[2]..name.."'s set #"..t[3]..args[2]..t[1].." ]==========")
                            if set.exists == true then
                                sender:sendMessage(t[2].."Owner Name: "..t[3]..name )
                                sender:sendMessage(t[2].."Owner UUID: "..t[3]..uuid )
                                sender:sendMessage(t[2].."Tier Rank: "..t[3].."Tier "..set.tier )
                                local slots = {}
                                for i = 1, set.slots do
                                    if type(set.slotn[i]) == "string" then
                                        table.insert(slots, set.slotn[i])
                                    end
                                end
                                sender:sendMessage(t[2].."Slots ("..#slots.."/"..set.slots.."): "..t[3]..table.concat(slots, ", "))
                            else
                                sender:sendMessage(t[2].."Error: "..t[3].."This tier set does not exist")
                            end
                        else
                            sender:sendMessage(t[2].."Error: "..t[3].."This tier set does not exist")
                        end
                    else
                        sender:sendMessage(t[2].."/tier info {id} [username]")
                        sender:sendMessage(t[3].."§oShow more information about your or [username]'s set {id}")
                    end
                elseif args[1] == "edit" then
                    local uuid = sender:getUniqueId():toString()
                    local name = sender:getName()
                    if args[2] and args[3] and args[4] then
                        args[2] = tonumber(args[2])
                        args[3] = tonumber(args[3])
                        if args[2] > 0 then
                            local set = loadset( uuid, args[2] )
                            if set.exists == true then
                                if args[3] > 0 and args[3] <= set.slots then
                                    if type(set.slotn[args[3]]) == "nil" then
                                        local target = server:getOfflinePlayer(args[4])
                                        local tname = target:getName()
                                        local tuuid = target:getUniqueId():toString()
                                        if target:isOnline() == true then
                                            -- Get the target's username and unique user identity
                                            if plugin.config.get( tuuid..".me.tier") then
                                               if plugin.config.get(tuuid..".me.tier") >= set.tier then
                                                    sender:sendMessage(t[2].."The player "..t[3]..tname..t[2].." has an equal or better tier already")
                                                    return
                                                end
                                            end
                                            set.slotn[args[3]] = tname
                                            set.slotu[args[3]] = tuuid
                                            saveset( uuid, args[2], set)
                                            plugin.config.set( tuuid..".me.tier", set.tier)
                                            plugin.config.set( tuuid..".me.id", args[2])
                                            plugin.config.set( tuuid..".me.pname", sender:getName())
                                            plugin.config.set( tuuid..".me.puuid", sender:getUniqueId():toString())
                                            plugin.config.save()
                                            local tr = plugin.config.get("config.tier"..set.tier..".name")
                                            server:dispatchCommand(server:getConsoleSender(), "pex user "..tname.." group add "..tr )
                                            sender:sendMessage(t[2].."Added "..t[3]..tname..t[2].." to your set of "..t[3].."Tier "..set.tier )
                                            target:sendMessage(t[3]..name..t[2].." added you their set of "..t[3].."Tier "..set.tier )
                                        else
                                            sender:sendMessage(t[2].."The player "..t[3]..tname..t[2].." is not currently online")
                                        end
                                    else
                                        sender:sendMessage(t[2].."Error: "..t[3].."Slot "..args[3]..t[2].." is already occupied")
                                    end
                                else
                                    sender:sendMessage(t[2].."Error: "..t[3].."Slot "..args[3]..t[2].." does not exist in that set")
                                end
                            else
                                sender:sendMessage(t[2].."Error: You do not own that tier set")
                            end
                        else
                            sender:sendMessage(t[2].."Error: You must state a number higher than zero")
                        end
                    else
                        sender:sendMessage(t[2].."/tier edit {id} {slot} {username}")
                        sender:sendMessage(t[3].."§oAdd {username} to slot {slot} of your set {id}")
                    end
                else
                    sender:sendMessage(t[1].."==========[ "..t[2].."Tier Command - Help "..t[1].."]==========")
                    sender:sendMessage(t[2].."Version: "..t[3]..plugin.version)
                    sender:sendMessage(t[2].."/tier list [username]")
                    sender:sendMessage(t[2].."/tier info {id} [username]")
                    sender:sendMessage(t[2].."/tier edit {id} {slot} {username}")
                end
            end
        )
        
        plugin.addCommand("tieradmin", "Administration command for Tiers", "/tieradmin",
            function(sender, args)
                if sender:hasPermission("tier.command.admin") == true then
                    if args[1] == "create" then
                        if args[2] and args[3] then
                            local offline = server:getOfflinePlayer(args[2])
                            local uuid = offline:getUniqueId():toString()
                            if plugin.config.get("config.tier"..args[3]..".enable") == true then
                                plugin.config.setDefault(uuid..".sets", 0)
                                plugin.config.save()
                                local id = plugin.config.get(uuid..".sets") + 1
                                local set = {}
                                set.tier = tonumber(args[3])
                                set.slots = plugin.config.get("config.slots")
                                if type( tonumber(args[4]) ) == "number" then
                                    if tonumber(args[4]) > 0 then
                                        set.slots = tonumber(args[4])
                                    end
                                end
                                set.exists = true
                                set.slotn = {}
                                set.slotu = {}
                                saveset(uuid, id, set)
                                plugin.config.set(uuid..".sets", id)
                                plugin.config.save()
                                sender:sendMessage(t[2].."Success: Created a set of "..t[3].."Tier "..set.tier..t[2].." for "..t[3]..offline:getName() )
                                if offline:isOnline() then
                                    offline:sendMessage(t[2].."Success: You have a new set of "..t[3].."Tier "..set.tier..t[2].." with "..set.slots.." slots")
                                end
                            else
                                if args[3] == "0" then
                                    sender:sendMessage(t[2].."Error: This parameter is used to nullify existing tiers.")
                                else
                                    sender:sendMessage(t[2].."Error: Unknown tier "..t[3]..args[3]..t[2]..". Try a number above 0")
                                end
                            end
                        else
                            sender:sendMessage(t[2].."Error: /tieradmin create {owner} {tier} [slots]")
                            sender:sendMessage(t[3].."§oCreate a new set of {tier} for {owner}")
                        end
                    elseif args[1] == "tier" then
                        if args[2] and args[3] and args[4] then
                            local offline = server:getOfflinePlayer(args[2])
                            args[3] = tonumber(args[3])
                            local uuid = offline:getUniqueId():toString()
                            local unrank = false
                            if args[4] == "0" then
                                unrank = true
                            end
                            args[4] = tonumber(args[4])
                            if type(args[3]) == "nil" then
                                sender:sendMessage(t[2].."Error: You must specify a number for {id}")
                                return
                            end
                            if type(args[4]) == "nil" and unrank == false then
                                sender:sendMessage(t[2].."Error: You must specify a number for {tier}")
                                return
                            end
                            local ns = "tier"..args[4]
                            if unrank == true then ns = "unranked" end
                            if plugin.config.get("config."..ns..".enable") == true then
                                if plugin.config.get(uuid.."."..args[3]..".tier") == args[4] and unrank == false then
                                    sender:sendMessage(t[2].."Error: This tier is already Tier "..args[4])
                                else
                                    local set = loadset(uuid, args[3])
                                    if set.tier > 0 then
                                        for i = 1, #set.slotu do
                                            server:dispatchCommand(server:getConsoleSender(), "pex user "..set.slotu[i].." group remove "..plugin.config.get("config.tier"..set.tier..".name"))
                                        end
                                    end
                                    local oldtier = set.tier
                                    if unrank == true then
                                        set.tier = 0
                                    else
                                        set.tier = args[4]
                                        for i = 1, #set.slotu do
                                            server:dispatchCommand(server:getConsoleSender(), "pex user "..set.slotu[i].." group add "..plugin.config.get("config.tier"..set.tier..".name"))
                                        end
                                    end
                                    saveset( uuid, args[3], set )
                                    if unrank == true then
                                        sender:sendMessage(t[2].."Success: Tier set has been suspended!")
                                    else
                                        sender:sendMessage(t[2].."Success: Changed from Tier "..oldtier.." to Tier "..args[4])
                                    end
                                    if offline:isOnline() == true then
                                        if unrank == true then
                                            offline:sendMessage(t[2].."Information: Your set "..args[3].." was marked as VOID by "..sender:getName())
                                        else
                                            offline:sendMessage(t[2].."Information: Your set "..args[3].." had its tier set at "..args[4])
                                        end
                                    end
                                end
                            else
                                sender:sendMessage(t[2].."Error: Tier "..args[4].." is disabled")
                            end
                        else
                            sender:sendMessage(t[2].."Error: /tieradmin tier {owner} {id} {tier}")
                            sender:sendMessage(t[3].."§oSets the tier of the set. Set {tier} to 0 to unrank")
                        end
                    elseif args[1] == "edit" then
                        if args[2] and args[3] and args[4] and args[5] then
                            local offline = server:getOfflinePlayer(args[2])
                            local ouuid = offline:getUniqueId():toString()
                            local oname = offline:getName()
                            args[3] = tonumber(args[3])
                            if type(args[3]) == "nil" then
                                sender:sendMessage(t[2].."Error: You must specify a number for {id}")
                                return
                            end
                            if type(args[4]) == "nil" then
                                sender:sendMessage(t[2].."Error: You must specify a number for {slot}")
                                return
                            end
                            args[4] = tonumber(args[4])
                            local set = loadset(ouuid, args[3])
                            if args[5] == "clear" then
                                if set.exists == true then
                                    if set.slotn[args[4]] then
                                        local old = server:getOfflinePlayer(set.slotn[args[4]])
                                        local olduuid = old:getUniqueId():toString()
                                        plugin.config.clear(ouuid.."."..args[3]..".slot."..args[4])
                                        plugin.config.clear(ouuid.."."..args[3]..".slot."..args[4])
                                        plugin.config.clear(olduuid..".me.tier")
                                        plugin.config.clear(olduuid..".me.id")
                                        plugin.config.clear(olduuid..".me.pname")
                                        plugin.config.clear(olduuid..".me.puuid")
                                        plugin.config.save()
                                        server:dispatchCommand(server:getConsoleSender(), "pex user "..old:getName().." group remove "..plugin.config.get("config.tier"..set.tier..".name"))
                                        sender:sendMessage(t[2].."Success: Removed "..old:getName().." from "..oname.."'s set")
                                        if old:isOnline() then
                                            old:sendMessage(t[2].."Information: "..sender:getName().." removed you from "..oname.."'s set")
                                        end
                                        if offline:isOnline() then
                                            offline:sendMessage(t[2].."Information: "..sender:getName().." removed "..old:getName().." from your set")
                                        end
                                    else
                                        sender:sendMessage(t[2].."Error: That slot is not occupied")
                                    end
                                else
                                    sender:sendMessage(t[2].."Error: That tier set does not exist")
                                end
                            else
                                local toffline = server:getOfflinePlayer(args[5])
                                local tuuid = toffline:getUniqueId():toString()
                                local tname = toffline:getName()
                            end
                        else
                            sender:sendMessage(t[2].."Error: /tieradmin edit {owner} {id} {slot} [{target}:clear]")
                        end
                    else    
                        sender:sendMessage(t[1].."==========[ §cTier Command - Admin "..t[1].."]==========")
                        sender:sendMessage(t[2].."Version: "..t[3]..plugin.version)
                        sender:sendMessage(t[2].."/tieradmin create {owner} {tier} [slots]")
                        sender:sendMessage(t[2].."/tieradmin tier {owner} {id} {tier}")
                        sender:sendMessage(t[2].."/tieradmin edit {owner} {id} {slot} [{username}:clear]")
                        sender:sendMessage(t[2].."/tieradmin immune {player} [true:false]")
                    end
                else
                    sender:sendMessage(t[2].."Error: You need permission "..t[3].."tier.command.admin"..t[2].." to run that")
                end
            end
        )
    end
)   
