#!/usr/bin/env lua

-- Import necessary modules
--
-- LuaDBI: https://zadzmo.org/code/luadbi/wiki/Quickstart.md
DBI = require('DBI')

-- Set the path to the Shotwell database.
-- During development, I'm working with a copy in the same directory.
-- This will need to be passed by Darktable once it's ready for testing there.
db_path = 'photo.db'

-- Derive a lookup table for tags, from TagTable.
-- Return a table:
-- key = integer index as used by Shotwell
-- value = tag in Darktable format
function tags_to_hash(db)
  -- Fetch the data from the db.
  statement, err = db:prepare('SELECT id, name FROM TagTable')
  assert(statement, err)
  statement:execute()

  -- Create an accumulator
  local map = {}

  -- Reformat the tags for use in Darktable:
  -- * remove any leading forward-slashes ('/')
  -- * replace forward-slashes between hierarchy levels, with pipes ('|')
  -- Note that top-level tags _without_ any hierarchy below them do _not_ have
  -- a leading forward-slash, so this special-case has to be handled.
  -- Darktable reference: https://docs.darktable.org/usermanual/3.8/en/module-reference/utility-modules/shared/tagging/
  for row in statement:rows(true) do
    map[row['id']] = string.gsub(string.gsub(row['name'], "^/", ""), "/", "|")
  end

  -- Remember to actually return the thing.
  return map
end


-- Create a new, sorted array of values from the input table.
-- Ignores the indices from the input table and does not modify it.
function sort_table_vals(tab)
  -- Create an accumulator
  local newtab = {}

  -- Iterate over the input table, inserting each value into the accumulator.
  for _, val in pairs(tab) do
    table.insert(newtab, val)
  end

  -- Sort the new table
  table.sort(newtab)

  -- Return the accumulator
  return newtab
end


-- This will become the function that generates a table of metadata from the photo table.
function print_photo_details(db)
  print("Preparing to list photographs")
  statement, err = db:prepare('SELECT filename, rating, backlinks FROM PhotoTable LIMIT 5')
  assert(statement, err)
  
  statement:execute()
  
  for row in statement:rows(true) do
    print(row['filename'] .. " Rating: " .. row['rating'])
  end
end


-- Convenient wrapper function that pulls everything together.
function main(path)
  -- Initialise the database connection
  dbd, err = DBI.Connect('SQLite3', path)
  assert (dbd, err)

  -- Extract a hashmap of tags
  tagmap = tags_to_hash(dbd)
  -- for index, tag in pairs(tagmap) do
  for _, tag in pairs(sort_table_vals(tagmap)) do
    print(tag)
  end
end


-- Invoke the main function, and actually do the thing.
main(db_path)
