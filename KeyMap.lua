--[[---------------------------------------------------------------------------

KeyMap
A dictionary/table type with parameterized key generation

Author: Fedge

]]-----------------------------------------------------------------------------

KeyMap = {}
KeyMap.__index = KeyMap

--- Constructs a table that guarantees its entries have unique keys.
-- @param #table tbl An existing table that will be re-keyed using the specified `keyfunc`.
-- @param #function keyfunc A function that returns a unique key for a specified value. The value is passed to the keyfunc on each invocation, so the keyfunc can use the value to generate a key.
-- @return #KeyMap self
-- @usage
-- 
-- function mult(a, b) return a*b end
-- local km0 = KeyMap:New({1, 2, 3, 4})                 -- passes through the original keys
-- local km1 = KeyMap:New({1, 2, 3, 4}, mult, 3)        -- calls the `mult` function
-- local km2 = KeyMap:New({1, 2, 3, 4}, function(v) return mult(v, 4) end) -- inline function, calls `mult`
-- 
function KeyMap:New(tbl, keyfunc, ...)
	local obj = {}
	setmetatable(obj, KeyMap)

	obj.data = {}

	if keyfunc then
		-- If a keyfunc was provided, assemble a local callable version with the correct params, and pcall it.
		local _keyfunc = function() return keyfunc( nil, unpack(arg) ) end
		local status, key = pcall(_keyfunc)
		-- If the keyfunc was called sucessfully, store the keyfunc
		if status then
			obj.keyfunc = _keyfunc
		end
	end

	if tbl then
	for k,v in pairs(tbl) do
		-- Set the newkey to be the table's original key, by default
		local newkey = k
	
		-- If we have a keyfunc, use the keyfunc to obtain a unique key.
		if obj.keyfunc then
		repeat newkey = obj.keyfunc(v) until not table.haskey(obj.data, newkey)
		end
		 
		obj.data[newkey] = v
	end
	end
	
	return obj
end

--- Inserts the specified `value` in the KeyMap.
-- @param value The value to insert
-- @param #string preferredKey The preferred key with which the specified `value` should be stored. Optional.
-- @return #boolean Returns whether the value was sucessfully inserted.
function KeyMap:insert(value, preferredKey)
	local newkey = preferredKey
	
	if not newkey then
	-- If no preferredKey was provided, we need to make our own.
	if self.keyfunc then
		repeat newkey = self.keyfunc(value) until not table.haskey(self.data, newkey)
	else
		return false
	end
	elseif table.haskey(self.data, newkey) then
	-- If the specified preferredKey is already in use, do not insert the value.
	return false
	end
	
	self.data[newkey] = value
	return newkey
end

--- Generates a unique key that is guaranteed to not already exist in the KeyMap.
-- Useful if you need a copy of the key before you have finish constructing the accompanying value.
-- You can pass the resulting key into the `insert` function as the `preferredKey` param.
-- @return #boolean The generated unique key.
function KeyMap:generatekey()
	assert(self.keyfunc ~= nil, "KeyMap does not have a keyfunc with which to generate a new key.")
	
	local newkey = nil
	repeat newkey = self.keyfunc(value) until not table.haskey(self.data, newkey)
	return newkey
end

function KeyMap:print()
	print("{")
	for k,v in pairs(self.data) do print("  ["..k.."] = " .. tostring(v)) end
	print("}")
end


KeySet = {}
function KeySet:New(tbl, keyfunc, ...)
	KeySet.__index = KeySet
	setmetatable(KeySet, {__index = KeyMap})
	
	local obj = KeyMap:New(tbl, keyfunc, arg)
	setmetatable(obj, KeySet)
	return obj
end

function KeySet:insert(value, preferredKey)
	if table.hasval(self, value) then print("shit"); return false end
	return KeyMap.insert(self, value, preferredKey)
end
