--[[---------------------------------------------------------------------------

Fedge's library of common lua functions

]]-----------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- string | common string functions
-------------------------------------------------------------------------------

--- Returns `true` if the string starts with the specified `prefix` string.
function string:startswith(prefix)
	return self:sub(1, #prefix) == prefix
end

--- Returns `true` if the string ends with the specified `suffix` string.
function string:endswith(suffix)
	return suffix == "" or self:sub(-#suffix) == suffix
end

function string:getRandChar()
	local cset = math.random(3)
	if cset == 1     then return string.char(math.random(48,57))
	elseif cset == 2 then return string.char(math.random(65,90))
	elseif cset == 3 then return string.char(math.random(97,122))
	end
end

-------------------------------------------------------------------------------
-- math | common math functions
-------------------------------------------------------------------------------

--- Returns the specified `value` clamped to a value within the range specified by `min` and `max`.
-- `guard_nil_value` will enforce a check against nil values of the `value` argument such that
-- the midpoint between `min` and `max` will be returned in cases where `value` is nil.
function math.clamp(value, min, max, guard_nil_value)
	local _lo = num.nonnil(min, -1e100)
	local _hi = num.nonnil(max,  1e100)

	if guard_nil_value then
		if (value == nil) and (min ~= nil) and (max ~= nil) then
			value = (min + max) / 2
		else
			value = num.nonnil(value, num.nonnil(max,  0))
		end
	end
	
	return math.min( math.max( value, _lo ), _hi )
end

-------------------------------------------------------------------------------
-- num | common numeric functions
-------------------------------------------------------------------------------

if not num then num = {} end

--- Returns the specified `value` if it is non-nil, or returns the specified `default` value.
-- Returns 0 if both `value` and `default` are nil.
function num.nonnil(value, default)
	local default = default and default or 0
	return value and value or default
end

--- Returns the specified `value` if it is greater or equal to the specified `limit`.
-- Otherwise, returns the specified `default` value.
function num.atleast(value, limit, default)
	local limit   = num.nonnil(limit, 0) 
	local default = num.nonnil(default, limit)
	
	-- the default value must be at least as large as the limit value
	if default < limit then default = limit end
	
	local value = num.nonnil(value, default)
	return (value >= limit and value or default)
end

--- Returns the specified `value` if it is less than or equal to the specified `limit`.
-- Otherwise, returns the specified `default` value.
function num.nolarger(value, limit, default)
	local value   = num.nonnil(value, num.nonnil(limit, 0))
	local limit   = num.nonnil(limit, 1e100) 
	local default = num.nonnil(default, limit)
	if default > limit then default = limit end
	return (value <= limit and value or default)
end

-------------------------------------------------------------------------------
-- table | common table functions
-------------------------------------------------------------------------------

--- Returns a boolean value indicating if the specified table `t` is empty.
function table.isempty(t)
	return next(t) == nil
end

--- Returns `true` if the specified table `t` contains the specified `key`.
function table.haskey(t, key)
	return t[key] ~= nil
end

--- Returns `true` if the specified table `t` contains the specified `value`.
function table.hasval(t, val)
	for k,v in pairs(t) do
		if v == val then return true end
	end
	return false
end

--- Returns a random key of the specified table.
function table.randkey(tbl)
	local keyset = {}
	for k in pairs(tbl) do table.insert(keyset, k) end
	return keyset[math.random(#keyset)]
end

--- Returns a random element of the specified table.
function table.randelement(tbl)
	return tbl[table.randkey(tbl)]
end

function table.map(tbl, f)
	local t = {}
	for k,v in pairs(tbl) do
		t[k] = f(v)
	end
	return t
end

function table.filter(tbl, f)
	local t = {}
	for k,v in pairs(tbl) do
		if f(v) then t[k] = v end
	end
	return t
end