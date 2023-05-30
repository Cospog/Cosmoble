--ServerScriptStorage
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

function Cosmoble.new(name: string, tbl: {})
	if not Cosmoble.activeTables[name] then
		Cosmoble.activeTables[name] = {}
		local proxyTable = {}
		local function sendChanges(tbl, key, val)
			if Cosmoble.activeTables[name] ~= {} then
				for i,v in pairs(Cosmoble.activeTables[name]) do
					v(tbl, key, val)
				end
			end
		end

		proxyTable.clear = function() return getmetatable(proxyTable).__newindex(proxyTable, nil) end
		proxyTable.insert = function(value: any) return getmetatable(proxyTable).__newindex(proxyTable, value) end
		proxyTable.remove = function(pos: number) return getmetatable(proxyTable).__newindex(proxyTable, pos, nil) end
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

		setmetatable(proxyTable, {
			__index = function(t, k)
				local val = tbl[k]
				if type(val) == "table" then
					val = Cosmoble.new("auto_"..tostring(k), val)
				end
				return val
			end,
			__newindex = function(t, k, v)
				print(tostring(k).." "..tostring(v))
				if not k then
					tbl = {}
				elseif not v then
					table.insert(tbl, k)
				else
					tbl[k] = v
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

return Cosmoble