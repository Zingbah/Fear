--##############################################################
--#### Local Variables and Functions


local function say(str) Fear.Say(str) end
local function alert(str) Fear.Alert(str) end
local function verbose(str) Fear.Verbose(str) end
local function addToLog(str) Fear.Log(str) end
local function addToDebug(str) Fear.Debug(str) end

-- Table Sort
local function __genOrderedIndex( t )
    local orderedIndex = {}
    for key in pairs(t) do
        table.insert( orderedIndex, key )
    end
    table.sort( orderedIndex )
    return orderedIndex
end

local function orderedNext(t, state)
    -- Equivalent of the next function, but returns the keys in the alphabetic
    -- order. We use a temporary ordered key table that is stored in the
    -- table being iterated.

    --print("orderedNext: state = "..tostring(state) )
    if state == nil then
        -- the first time, generate the index
        t.__orderedIndex = __genOrderedIndex( t )
        key = t.__orderedIndex[1]
        return key, t[key]
    end
    -- fetch the next value
    key = nil
    for i = 1,table.getn(t.__orderedIndex) do
        if t.__orderedIndex[i] == state then
            key = t.__orderedIndex[i+1]
        end
    end

    if key then
        return key, t[key]
    end

    -- no more value to return, cleanup
    t.__orderedIndex = nil
    return
end

--##############################################################
-- Functions
function DeepCopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return new_table
    end
    return _copy(object)
end

function TableMerge(t1,t2)
   local t3=DeepCopy(t1)
   for k,v in pairs(t2) do
      if type(v)=="table" and type(t1[k])=="table" then
         t3[k]=TableMerge(t1[k],v)
      else
         t3[k]=v
      end
   end
   return t3
end

function GetField(f)
  local v = _G    -- start with the table of globals
  for w in string.gfind(f, "[%w_]+") do
    v = v[w]
  end
  return v
end

function SetField(f, v)
  local t = _G    -- start with the table of globals
  for w, d in string.gfind(f, "([%w_]+)(.?)") do
    if d == "." then      -- not last field?
      t[w] = t[w] or {}   -- create table if absent
      t = t[w]            -- get the table
    else                  -- last field
        if t[w] then
            t[w] = v            -- do the assignment
        else
            return false
        end
    end
  end
end

function OrderedPairs(t)
    -- Equivalent of the pairs() function on tables. Allows to iterate
    -- in order
    return orderedNext, t, nil
end


function OrderedTable(fcomp)
   -- OrderedTable( [comp] )
   -- Returns an ordered table. Can only take strings as index.
   -- fcomp is a comparison function behaves behaves just like
   -- fcomp in table.sort( t [, fcomp] ).
  local newmetatable = {}
  
  -- sort func
  newmetatable.fcomp = fcomp

  -- sorted subtable
  newmetatable.sorted = {}

  -- behavior on new index
  function newmetatable.__newindex(t, key, value)
    if type(key) == "string" then
      local fcomp = getmetatable(t).fcomp
      local tsorted = getmetatable(t).sorted
      Binsert(tsorted, key , fcomp)
      rawset(t, key, value)
    end
  end

  -- behaviour on indexing
  function newmetatable.__index(t, key)
    if key == "n" then
      return table.getn( getmetatable(t).sorted )
    end
    local realkey = getmetatable(t).sorted[key]
    if realkey then
      return realkey, rawget(t, realkey)
    end
  end

  local newtable = {}

  -- set metatable
  return setmetatable(newtable, newmetatable)
end 
      
function Binsert(t, value, fcomp)
   --// Binsert( table, value [, comp] )
   --
   -- LUA 5.x add-on for the table library.
   -- Does binary insertion of a given value into the table
   -- sorted by [,fcomp]. fcomp is a comparison function
   -- that behaves like fcomp in in table.sort(table [, fcomp]).
   -- This method is faster than doing a regular
   -- table.insert(table, value) followed by a table.sort(table [, comp]).
   
  -- Initialise Compare function
  local fcomp = fcomp or function( a, b ) return a < b end

  --  Initialise Numbers
  local iStart, iEnd, iMid, iState =  1, table.getn( t ), 1, 0

  -- Get Insertposition
  while iStart <= iEnd do
    -- calculate middle
    iMid = math.floor( ( iStart + iEnd )/2 )

    -- compare
    if fcomp( value , t[iMid] ) then
      iEnd = iMid - 1
      iState = 0
    else
      iStart = iMid + 1
      iState = 1
    end
  end

  local pos = iMid+iState
  table.insert( t, pos, value )
  return pos
end

-- Iterate in ordered form
-- returns 3 values i, index, value
-- ( i = numerical index, index = tableindex, value = t[index] )
function OrderedPairs(t)
  return orderedNext, t
end


