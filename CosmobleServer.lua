--ServerScriptService
local Cosmoble = {activeTables = {}}


local function tblToString(tbl)
	local str = "{"
	for i, v in pairs(tbl) do
		if type(v) == "table" then
			str = str..tostring(i).." = "..tblToString(v)..", "
		else
			str = str..tostring(i).." = "..tostring(v)..", "
		end
	end
	if str ~= "{" then
		str = str:sub(1, -3)
	end
	return str.."}"
end

function Cosmoble.new(name: string, tbl: {}, player)
	if not Cosmoble.activeTables[name] then
		Cosmoble.activeTables[name] = {}
		local proxyTable = {}
		local function sendChanges(key, val)
			if Cosmoble.activeTables[name] ~= {} then
				for i,v in pairs(Cosmoble.activeTables[name]) do
					if i ~= "proxyTableAuto" then
						v(key, val)
					end
				end
				if player then
					game.ReplicatedStorage.CosmobleShared.CosmobleEvent:FireClient(player, name, key, val)
				else
					game.ReplicatedStorage.CosmobleShared.CosmobleEvent:FireAllClients(name, key, val)
				end
			end
		end
		proxyTable.clear = function() return getmetatable(proxyTable).__newindex(proxyTable, nil) end
		proxyTable.insert = function(value: any) return getmetatable(proxyTable).__newindex(proxyTable, value) end
		proxyTable.remove = function(pos: number) return getmetatable(proxyTable).__newindex(proxyTable, pos, "delete") end
		proxyTable.find = function(needle: any, init: number) return table.find(tbl, needle, init) end
		proxyTable.concat = function(sep: string, i: number, j: number) return table.concat(tbl, sep, i, j) end
		proxyTable.clone = function() return table.clone(tbl) end
		proxyTable.move = function(a: number, b: number, t: number, dst: {}) return table.move(tbl, a, b, t, dst) end
		proxyTable.sort = function(comp)
			for i = 1, #proxyTable do
				for i2 = i+1, #proxyTable do
					if comp(proxyTable[i2], proxyTable[i]) then
						proxyTable.__newindex(proxyTable, i, proxyTable[i2])
						proxyTable.__newindex(proxyTable, i2, proxyTable[i])
					end
				end
			end
		end
		proxyTable.original = function() return tbl end
		setmetatable(proxyTable, {
			__index = function(t, k)
				local val = tbl[k]
				if type(val) == "table" then
					if player then
						val = Cosmoble.new(player.UserId.."_auto_"..tostring(k), val, player)
					else
						val = Cosmoble.new("auto_"..tostring(k), val, player)
					end
				end
				return val
			end,
			__newindex = function(t, k, v)
				print(tostring(k).." "..tostring(v))
				if v == "delete" then
					table.remove(tbl, k)
					sendChanges(k, nil)
				elseif not k then
					tbl = {}
					sendChanges(tbl)
				elseif not v then
					table.insert(tbl, k)
					sendChanges(tbl, k)
				else
					tbl[k] = v
					sendChanges(k, v)
				end
			end,
			__tostring = function() return tblToString(tbl) end
		})
		Cosmoble.activeTables[name].proxyTableAuto = proxyTable
		return proxyTable
	else
		return Cosmoble.activeTables[name].proxyTableAuto
	end
end

function Cosmoble.get(cosmobleName: string)
	if Cosmoble.activeTables[cosmobleName] then
		return Cosmoble.activeTables[cosmobleName].proxyTableAuto
	end
end
function Cosmoble.destroy(name: string)
	if Cosmoble.activeTables[name] then
		Cosmoble.activeTables[name] = nil
	end
end

function Cosmoble:connectCosmoble(cosmobleName: string, connectionName: string, func)
	local cosmobleTblData = Cosmoble.activeTables[cosmobleName]
	if cosmobleTblData and not cosmobleTblData[connectionName] then
		cosmobleTblData[connectionName] = func
	end
end

function Cosmoble:disconnectCosmoble(cosmobleName: string, connectionName: string)
	local cosmobleTblData = Cosmoble.activeTables[cosmobleName]
	if cosmobleTblData and cosmobleTblData[connectionName] then
		cosmobleTblData[connectionName] = nil
	end
end

game.ReplicatedStorage.CosmobleShared.CosmobleEvent.OnServerEvent:Connect(function(plr, cosmobleName)
	local receivedCosmoble = Cosmoble.get(cosmobleName)
	if receivedCosmoble then
		return Cosmoble.get(cosmobleName).original()
	end
end)

return Cosmoble
