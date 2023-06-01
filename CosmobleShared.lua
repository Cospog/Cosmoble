--ReplicatedStorage
-- Create a table named Cosmoble with an empty table named activeTables inside it
local Cosmoble = {activeTables = {}}

script.CosmobleEvent.OnClientEvent:Connect(function(cosmobleName, key, value)
	if Cosmoble.activeTables[cosmobleName] then
		for i,v in pairs(Cosmoble.activeTables[cosmobleName]) do
			v(key, value)
		end
	end
end)

function Cosmoble:connectCosmoble(cosmobleName: string, connectionName: string, func)
	if not Cosmoble.activeTables[cosmobleName] then
		Cosmoble.activeTables[cosmobleName] = {}
		Cosmoble.activeTables[cosmobleName][connectionName] = func
	elseif not Cosmoble.activeTables[cosmobleName][connectionName] then
		Cosmoble.activeTables[cosmobleName][connectionName] = func
	end
end

function Cosmoble:disconnectCosmoble(cosmobleName: string, connectionName: string)
	local cosmobleTblData = Cosmoble.activeTables[cosmobleName]
	if cosmobleTblData and cosmobleTblData[connectionName] then
		cosmobleTblData[connectionName] = nil
	end
end

function Cosmoble.get(cosmobleName: string)
	return script.CosmobleFunction:InvokeServer(cosmobleName)
end

return Cosmoble
