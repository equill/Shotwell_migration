#!/usr/bin/env lua

-- Import necessary modules
--
-- LuaDBI: https://zadzmo.org/code/luadbi/wiki/Quickstart.md
DBI = require('DBI')

-- Set the path to the Shotwell database.
-- During development, I'm working with a copy in the same directory.
-- This will need to be passed by Darktable once it's ready for testing there.
db_path = 'photo.db'


--- Shotwell functions
--
-- These are for extracting data from the Shotwell database


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
-- The reason for doing this is to work with the way Darktable handles hierarchical tags
-- when creating them: we need to create the parent tags first, then their dependents.
-- Sorting the tags themselves in lexicographic order puts them in the right order.
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


-- Helper function: extract the list of tag indices from the "backlinks" field
-- and return it as an array of integers.
-- This is necessary due to the interesting design decision of encoding multiple
-- separate lists of attributes as a newline-separated series of pipe-separate strings
-- in a single field.
function extract_tag_indices(backlinks)
  -- Create an accumulator
  local taglist = {}

  -- Check whether it was null.
  -- If not, carry on with the extraction
  if backlinks then
    -- Extract the 'tag=[<number>|]..<newline> sequence,
    -- and iterate over the numbers within it.
    indexlist = string.match(backlinks, 'tag=[(%d+)|]*')
    if indexlist then
      for index in string.gmatch(indexlist, '(%d+)') do
        table.insert(taglist, index)
      end
    end
  end

  -- Return the accumulator
  return taglist
end


-- Extract photo data from the database.
-- Return it as a table:
-- key = filename
-- value = {rating: <rating>, tags: {<list of tag indices>}}
function extract_photo_details(db)
  -- Fetch the raw data
  statement, err = db:prepare('SELECT filename, rating, backlinks FROM PhotoTable ORDER BY filename')
  assert(statement, err)
  statement:execute()

  -- Create an accumulator
  local photos = {}

  -- Iterate over the rows, and extract the results
  for row in statement:rows(true) do
    photos[row['filename']] = { ["rating"] = row['rating'];
                                ["tags"] = extract_tag_indices(row['backlinks']) }
  end

  -- Return the result
  return photos
end


--- Darktable functions
--
-- These are for importing files, adding tags etc. into Darktable.


--- Main section
--
-- Functions that make use of everything defined so far

-- Convenient wrapper function that pulls everything together.
function main(path)
  -- Initialise the database connection
  dbd, err = DBI.Connect('SQLite3', path)
  assert (dbd, err)

  -- Extract a hashmap of tags
  tagmap = tags_to_hash(dbd)

  -- Get the ordered list of tags,
  -- to ensure they exist in Darktable before trying to associate them with images.
  sorted_tags = sort_table_vals(tagmap)

  -- Extract a list of photos
  photomap = extract_photo_details(dbd)

  -- PoC: confirm we got the tags in order, by printing them out.
  for filename, details in pairs(photomap) do
    print(filename .. ': rating = ' .. details.rating .. '; tags: ' .. table.concat(details.tags, ', '))
  end
end


-- Invoke the main function, and actually do the thing.
main(db_path)
