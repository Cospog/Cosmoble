--ReplicatedStorage
-- Create a table named Cosmoble with an empty table named activeTables inside it
local Cosmoble = {activeTables = {}}

-- Connect to a client event named CosmobleEvent
script.CosmobleEvent.OnClientEvent:Connect(function(cosmobleName, tbl, key, value)
	-- Check if there are any active tables associated with the given cosmobleName
	if Cosmoble.activeTables[cosmobleName] then
		-- Iterate over all the connections in the activeTables for the given cosmobleName
		for i,v in pairs(Cosmoble.activeTables[cosmobleName]) do
			-- Call the connection function with the provided arguments
			v(tbl, key, value)
		end
	end
end)

-- Define a function named connectCosmoble within the Cosmoble table
function Cosmoble:connectCosmoble(cosmobleName: string, connectionName: string, func)
	-- Check if there are no active tables associated with the given cosmobleName
	if not self.activeTables[cosmobleName] then
		-- Create a new table inside activeTables for the given cosmobleName
		self.activeTables[cosmobleName] = {}
		-- Add the provided connection function with the given connectionName to the newly created table
		self.activeTables[cosmobleName][connectionName] = func
		-- If there are active tables associated with the given cosmobleName
	elseif not self.activeTables[cosmobleName][connectionName] then
		-- Add the provided connection function with the given connectionName to the existing active table
		self.activeTables[cosmobleName][connectionName] = func
	end
end

-- Define a function named disconnectCosmoble within the Cosmoble table
function Cosmoble:disconnectCosmoble(cosmobleName: string, connectionName: string)
	-- Get the table data associated with the given cosmobleName
	local cosmobleTblData = self.activeTables[cosmobleName]
	-- Check if the table data exists and if there is a connection with the given connectionName
	if cosmobleTblData and cosmobleTblData[connectionName] then
		-- Remove the connection from the active table
		cosmobleTblData[connectionName] = nil
	end
end

-- Return the Cosmoble table to make it accessible when this module is required
return Cosmoble
