--ServerScriptService
local Cosmoble = {activeTables = {}}

function Cosmoble.new(name: any, tbl: {}, plr: Player?)
	if not Cosmoble.activeTables[name] then
		Cosmoble.activeTables[name] = {}
		local proxyTable = newproxy(true)
		local metaProxyTable = getmetatable(proxyTable)
		local function sendChanges(key, val)
			if Cosmoble.activeTables[name] ~= {} then
				for i,v in pairs(Cosmoble.activeTables[name]) do
					if i ~= "proxyTableAuto" then
						v(key, val)
					end
				end
				if plr then
					game.ReplicatedStorage.CosmobleShared.CosmobleEvent:FireClient(plr, name, key, val)
				else
					game.ReplicatedStorage.CosmobleShared.CosmobleEvent:FireAllClients(name, key, val)
				end
			end
		end	
		local proxyMethods = {
			insert = function(value: any) return metaProxyTable.__newindex(proxyTable, #proxyTable+1, value) end,
			remove = function(pos: number) return metaProxyTable.__newindex(proxyTable, pos, nil) end,
			find = function(needle: any, init: number) return table.find(tbl, needle, init) end,
			concat = function(sep: string, i: number, j: number) return table.concat(tbl, sep, i, j) end,
			clone = function() return table.clone(tbl) end,
			move = function(a: number, b: number, t: number, dst: {}) return table.move(tbl, a, b, t, dst) end,
			original = function() return tbl end,
			inpairs = function(func) for i,v in pairs(tbl) do func(i,v) end end
		}
		metaProxyTable.__index = function(s,k)
			local val = tbl[k] or proxyMethods[k]
			local plrId = ""
			if plr and plr.UserId then plrId = plr.UserId.."_" end
			if type(val) == "table" then return Cosmoble.new(plrId.."auto_"..tostring(k), val, plr) end
			return val
		end
		metaProxyTable.__newindex = function(self,k,v)
			sendChanges(k,v)
			tbl[k] = v
		end
		metaProxyTable.__iter = function() return next, tbl end
		metaProxyTable.__len = function() return #tbl end
		Cosmoble.activeTables[name].proxyTableAuto = proxyTable
		return proxyTable
	else
		return Cosmoble.activeTables[name].proxyTableAuto
	end
end

function Cosmoble.get(cosmobleName: any)
	if Cosmoble.activeTables[cosmobleName] then
		return Cosmoble.activeTables[cosmobleName].proxyTableAuto
	end
end
function Cosmoble.destroy(name: any)
	if Cosmoble.activeTables[name] then
		Cosmoble.activeTables[name] = nil
	end
end

function Cosmoble:connectCosmoble(cosmobleName: any, connectionName: string, func)
	local cosmobleTblData = Cosmoble.activeTables[cosmobleName]
	if cosmobleTblData and not cosmobleTblData[connectionName] then
		cosmobleTblData[connectionName] = func
	end
end

function Cosmoble:disconnectCosmoble(cosmobleName: any, connectionName: string)
	local cosmobleTblData = Cosmoble.activeTables[cosmobleName]
	if cosmobleTblData and cosmobleTblData[connectionName] then
		cosmobleTblData[connectionName] = nil
	end
end


game.ReplicatedStorage.CosmobleShared.CosmobleFunction.OnServerInvoke = function(plr, cosmobleName)
	local receivedCosmoble = Cosmoble.get(cosmobleName)
	if receivedCosmoble then
		return Cosmoble.get(cosmobleName).original()
	end
end

return Cosmoble
