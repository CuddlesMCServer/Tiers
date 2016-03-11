local Tiers = lukkit.addPlugin("Tiers", "v1.0-alpha1",
    function( plugin )
        
        plugin.onEnable(
            function()
                plugin.config.setDefault( "config.slots", 3 )
                -- Which ranks should be enabled? Default set to all disabled because yeah
                plugin.config.setDefault( "config.tier1.enable", false )
                plugin.config.setDefault( "config.tier2.enable", false )
                plugin.config.setDefault( "config.tier3.enable", false )
                plugin.config.setDefault( "config.tier4.enable", false )
                -- What is each rank named in PermissionsEx?
                plugin.config.setDefault( "config.tier0.rank", "Default" )
                plugin.config.setDefault( "config.tier1.rank", "Tier1" )
                plugin.config.setDefault( "config.tier2.rank", "Tier2" )
                plugin.config.setDefault( "config.tier3.rank", "Tier3" )
                plugin.config.setDefault( "config.tier4.rank", "Tier4" )
                plugin.config.setDefault( "config.staff.rank", "StaffOffDuty" )
                -- What are the friendly names of each rank?
                plugin.config.setDefault( "config.tier0.name", "§eUnranked" )
                plugin.config.setDefault( "config.tier1.name", "§9Tier 1" )
                plugin.config.setDefault( "config.tier2.name", "§2Tier 2" )
                plugin.config.setDefault( "config.tier3.name", "§6Tier 3" )
                plugin.config.setDefault( "config.tier4.name", "§5Tier 4" )
                plugin.config.setDefault( "config.staff.name", "§4Staff Member" )
                -- What are the permission nodes for each rank to identify them?
                plugin.config.setDefault( "config.tier0.perm", "tier.zero" )
                plugin.config.setDefault( "config.tier1.perm", "tier.one" )
                plugin.config.setDefault( "config.tier2.perm", "tier.two" )
                plugin.config.setDefault( "config.tier3.perm", "tier.three" )
                plugin.config.setDefault( "config.tier4.perm", "tier.four" )
                plugin.config.setDefault( "config.staff.perm", "tier.staff" )
                -- Finally, save the contents to disk
                plugin.config.save()
            end
        )
        
        function loadset(owner_uuid, set_id)
            local set = {}
            if plugin.config.get( owner_uuid .. "." .. set_id .. ".exists" ) then
                set.exists = true
                set.tier = plugin.config.get( owner_uuid .. "." .. set_id .. ".tier") 
                set.slots = plugin.config.get( owner_uuid .. "." .. set_id .. ".slots" )
                set.slotn = {}
                set.slotu = {}
                for n = 1, set.slots do
                    if plugin.config.get( owner_uuid .. "." ..set_id .. "." .. n) then
                        set.slotn[n] = plugin.config.get( owner_uuid .. "." .. set_id .. ".n." .. n)
                        set.slotu[n] = plugin.config.get( owner_uuid .. "." .. set_id .. ".u." .. n)
                    end
                end
                return true, set
            else
                return false, {}
            end
        end
        
        function saveset(owner_uuid, set_id, set)
            if set.exists then plugin.config.set(owner_uuid.."."..set_id..".exists", true) end
            if set.tier then plugin.config.set(owner_uuid.."."..set_id..".tier", set.tier) end
            if set.slots then plugin.config.set(owner_uuid.."."..set_id..".slots", set.slots) end
            if set.slotn and set.slotu then
                for n = 1, set.slots do
                    if set.slotn[n] then
                        plugin.config.set(owner_uuid.."."..set_id..".n."..n, set.slotn[n]) 
                    end
                    if set.slotu[n] then
                        plugin.config.set(owner_uuid.."."..set_id..".u."..n, set.slotu[n]) 
                    end
                end
            end
            plugin.config.save()
        end
        
        plugin.addCommand("tier", "Show information about tier sets", "/tier help",
            function(sender, args)
                if args[1] == "info" or args[1] == "i" then
                    if args[2] and args[3] then
                        local offline = server:getOfflinePlayer(args[2])
                        local exists, set = loadset(offline:getUniqueId():toString(), tonumber(args[3]))
                        sender:sendMessage("§2==========[ §aTier Set #"..args[3].." §2|§a "..offline:getName().." §2]==========")
                        if exists == true then
                            sender:sendMessage("§2Owner UUID: §a"..offline:getUniqueId():toString())
                            sender:sendMessage("§2Rank: "..plugin.config.get("config.tier"..set.tier..".name"))
                            sender:sendMessage("§2Members: §a"..table.concat(set.slotn, ", "))
                        else
                            sender:sendMessage("§cThat tier set does not exist yet.")
                        end
                    else
                        sender:sendMessage("§a/tier info [username] [id]")
                        sender:sendMessage("§7§o Show information about the specified tier set")
                    end
                elseif args[1] == "list" or args[1] == "l" then
                    if args[2] then
                        local offline = server:getOfflinePlayer(args[2])
                        local uuid = offline:getUniqueId():toString()
                        plugin.config.setDefault(uuid..".count", 0)
                        plugin.config.save()
                        local total = plugin.config.get(uuid..".count")
                        plugin.print("Total: "..total)
                        local count = 0
                        sender:sendMessage("§2==========[ §aTier List §2|§a "..offline:getName().." §2]==========")
                        for id = 1, total do
                            sender:sendMessage("§2Set #"..id.." is a set of: "..plugin.config.get("config.tier"..(plugin.config.get(uuid.."."..id..".tier"))..".name"))
                            count = count + 1
                        end
                        if count == 0 then
                            sender:sendMessage("§cThis user does not yet have any tier sets.")
                        end
                    else
                        sender:sendMessage("§a/tier list [username]")
                        sender:sendMessage("§7§o Show a list of tiers that this player owns")
                    end
                elseif args[1] == "add" or args[1] == "a" then
                    if args[2] and args[3] and args[4] then
                        local offline = sender:getPlayer()
                        local target = server:getOfflinePlayer(args[4])
                        local tname = target:getName()
                        local tuuid = target:getUniqueId():toString()
                        local ouuid = offline:getUniqueId():toString()
                        local exists, set = loadset(ouuid, args[2])
                        if exists == true then
                            local s = tonumber(args[3])
                            if set.slotn[s] then
                                sender:sendMessage("§cThis slot is taken by "..set.slotn[s])
                            else
                                set.slotn[s] = tname
                                set.slotu[s] = tuuid
                                saveset(ouuid, tonumber(args[2]), set)
                                sender:sendMessage("§aAdded §f"..tname.." §ato this set successfully")
                            end
                        else
                            if tname == "PineLily" then
                                sender:sendMessage("§cTier set does not exist, m'lady")
                            elseif tname == "zach1231x" then
                                sender:sendMessage("§cTier set does not exist. Check your privilege")
                            else
                                sender:sendMessage("§cTier set does not exist.")
                            end
                        end
                    else
                        sender:sendMessage("§a/tier add [id] [slot] [username]")
                        sender:sendMessage("§7§o Add someone to the specified slot in the tier set")
                    end
                elseif args[1] == "admin" or args[1] == "ad" then
                    if sender:hasPermission("tier.staff") then
                        if args[2] == "create" or args[2] == "c" then
                            if args[3] and args[4] then -- args[3] is username, args[4] is tier level
                                local offline = server:getOfflinePlayer(args[3])
                                local tier = tonumber(args[4])
                                if tier < 1 or tier > 4 then
                                    sender:sendMessage("§cThis is not a valid tier. Must be a number 1 - 4")
                                else
                                    -- Place creation script here
                                    local set = {}
                                    set.exists = true
                                    set.tier = tier
                                    set.slots = plugin.config.get("config.slots")
                                    local uuid = offline:getUniqueId():toString()
                                    plugin.config.setDefault(uuid..".count", 0)
                                    plugin.config.save()
                                    local id = plugin.config.get(uuid..".count") + 1
                                    saveset(uuid, id, set)
                                    plugin.config.set(uuid..".count", 1)
                                    plugin.config.save()
                                    sender:sendMessage("§aCreated a new set of "..plugin.config.get("config.tier"..tier..".name").." §afor "..offline:getName())
                                end
                            else
                                sender:sendMessage("§c/tier admin create [username] [tier]")
                                sender:sendMessage("§7§o Create a tier set for the player with username.")
                            end
                        elseif args[2] == "upgrade" or args[2] == "u" then
                            if args[3] and args[4] then -- args[3] is username, args[4] is the ID, args[5] is new tier level
                                
                                
                                
                            else
                                sender:sendMessage("§c/tier admin upgrade [username] [id] [tier]")
                                sender:sendMessage("§7§o Upgrade a tier set to the new tier level")
                            end
                        elseif args[2] == "reset" or args[2] == "r" then
                        else
                            sender:sendMessage("§4==========[ §cTier Admin §4|§c "..plugin.version.." §4]==========")
                            sender:sendMessage("§c/tier admin create [username] [tier]")
                            sender:sendMessage("§7§o Create a tier set for the player with username.")
                            sender:sendMessage("§c/tier admin upgrade [username] [id] [tier]")
                            sender:sendMessage("§7§o Upgrade a tier set to the new tier level")
                        end
                    else
                        sender:sendMessage("§cYou need the permission node §ftier.staff§c to run this.")
                    end
                else
                    sender:sendMessage("§2==========[ §aTier Command §2|§a "..plugin.version.." §2]==========")
                    sender:sendMessage("§a/tier info [username] [id]")
                    sender:sendMessage("§7§o Show information about the specified tier set")
                    sender:sendMessage("§a/tier list [username]")
                    sender:sendMessage("§7§o Show a list of tiers that this player owns")
                    sender:sendMessage("§a/tier add [id] [slot] [username]")
                    sender:sendMessage("§7§o Add someone to a slot in your set")
                    if sender:hasPermission("tier.staff") == true then
                        sender:sendMessage("§c/tier admin create [username] [tier]")
                        sender:sendMessage("§7§o Create a tier set for the player with username.")
                        sender:sendMessage("§c/tier admin upgrade [username] [id] [tier]")
                        sender:sendMessage("§7§o Upgrade a tier set to the new tier level")
                    end
                end
            end
        )
    end
)
