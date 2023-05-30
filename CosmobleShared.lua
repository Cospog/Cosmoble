--ReplicatedStorage
-- Create a table named Cosmoble with an empty table named activeTables inside it
local Cosmoble = {activeTables = {}}

script.CosmobleEvent.OnClientEvent:Connect(function(cosmobleName, tbl, key, value)
	if Cosmoble.activeTables[cosmobleName] then
		for i,v in pairs(Cosmoble.activeTables[cosmobleName]) do
			v(tbl, key, value)
		end
	end
end)

function Cosmoble:connectCosmoble(cosmobleName: string, connectionName: string, func)
	if not self.activeTables[cosmobleName] then
		self.activeTables[cosmobleName] = {}
		self.activeTables[cosmobleName][connectionName] = func
	elseif not self.activeTables[cosmobleName][connectionName] then
		self.activeTables[cosmobleName][connectionName] = func
	end
end

function Cosmoble:disconnectCosmoble(cosmobleName: string, connectionName: string)
	local cosmobleTblData = self.activeTables[cosmobleName]
	if cosmobleTblData and cosmobleTblData[connectionName] then
		cosmobleTblData[connectionName] = nil
	end
end

return Cosmoble
