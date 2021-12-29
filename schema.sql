-- "PhotoTable maintains information on all photos imported into the library."
-- "Most of its fields are self-explanatory."
CREATE TABLE PhotoTable (
  id INTEGER PRIMARY KEY, -- 
  filename TEXT UNIQUE NOT NULL,
  width INTEGER,
  height INTEGER,
  filesize INTEGER,
  timestamp INTEGER,
  exposure_time INTEGER,
  orientation INTEGER,
  original_orientation INTEGER,
  -- import_id = timestamp taken at the start of an import batch.
  -- NOT a foreign key.
  import_id INTEGER,
  --
  event_id INTEGER,
  -- All transformations other than orientation (i.e. crop, color adjustment, etc.)
  -- are stored as a text KeyFile in the transformations column.
  transformations TEXT,
  --
  md5 TEXT, -- Full MD5 hash of the entire file.
  thumbnail_md5 TEXT, -- MD5 hash of the embedded preview.
  exif_md5 TEXT,  -- MD5 hash of only the EXIF data, excluding the preview.
  time_created INTEGER,
  flags INTEGER DEFAULT 0,
  rating INTEGER DEFAULT 0,
  --
  file_format INTEGER DEFAULT 0,
  -- 0 = jpg
  -- 1 = cr2 (? all RAW formats)
  -- 2 = png
  -- 3 = tif/tiff
  -- 4 = bmp
  -- 5 = gif
  -- 6 = webp
  --
  title TEXT,
  -- backlinks are persistent links to container objects, i.e. Events and Tags.
  -- These are used if the photo is removed and subsequently un-trashed,
  -- to restore its connections to those containers.
  backlinks TEXT,
  --
  time_reimported INTEGER,
  editable_id INTEGER DEFAULT -1,
  metadata_dirty INTEGER DEFAULT 0,
  developer TEXT,
  develop_shotwell_id INTEGER DEFAULT -1,
  develop_camera_id INTEGER DEFAULT -1,
  develop_embedded_id INTEGER DEFAULT -1,
  comment TEXT,
  has_gps INTEGER DEFAULT -1,
  gps_lat REAL,
  gps_lon REAL
);

CREATE TABLE TagTable (
  id INTEGER PRIMARY KEY,
  name TEXT UNIQUE NOT NULL,
  photo_id_list TEXT,
  time_created INTEGER
);

CREATE TABLE VideoTable (
  id INTEGER PRIMARY KEY,
  filename TEXT UNIQUE NOT NULL,
  width INTEGER,
  height INTEGER,
  clip_duration REAL,
  is_interpretable INTEGER,
  filesize INTEGER,
  timestamp INTEGER,
  exposure_time INTEGER,
  import_id INTEGER,
  event_id INTEGER,
  md5 TEXT,
  time_created INTEGER,
  rating INTEGER DEFAULT 0,
  title TEXT,
  backlinks TEXT,
  time_reimported INTEGER,
  flags INTEGER DEFAULT 0,
  comment TEXT
);

-- The follow tables are not of use when exporting

CREATE TABLE VersionTable (
  id INTEGER PRIMARY KEY,
  schema_version INTEGER,
  app_version TEXT,
  user_data TEXT NULL
);

-- In Shotwell, an event is a grouping of photos based on the time of their exposure.
-- I don't use this, so I've ignored it.
CREATE TABLE EventTable (id INTEGER PRIMARY KEY, name TEXT, primary_photo_id INTEGER, time_created INTEGER,primary_source_id TEXT,comment TEXT);

-- Only used when a picture is edited externally, and does not hold transformation data.
CREATE TABLE BackingPhotoTable (id INTEGER PRIMARY KEY, filepath TEXT UNIQUE NOT NULL, timestamp INTEGER, filesize INTEGER, width INTEGER, height INTEGER, original_orientation INTEGER, file_format INTEGER, time_created INTEGER );

-- Marks photos as "not where I left it; presumed deleted."
-- This information can be inferred more efficiently by probing the filepath.
CREATE TABLE TombstoneTable (id INTEGER PRIMARY KEY, filepath TEXT NOT NULL, filesize INTEGER, md5 TEXT, time_created INTEGER, reason INTEGER DEFAULT 0 );

CREATE TABLE SavedSearchDBTable (id INTEGER PRIMARY KEY, name TEXT UNIQUE NOT NULL, operator TEXT NOT NULL);
CREATE TABLE SavedSearchDBTable_Text (id INTEGER PRIMARY KEY, search_id INTEGER NOT NULL, search_type TEXT NOT NULL, context TEXT NOT NULL, text TEXT);
CREATE TABLE SavedSearchDBTable_MediaType (id INTEGER PRIMARY KEY, search_id INTEGER NOT NULL, search_type TEXT NOT NULL, context TEXT NOT NULL, type TEXT NOT_NULL);
CREATE TABLE SavedSearchDBTable_Flagged (id INTEGER PRIMARY KEY, search_id INTEGER NOT NULL, search_type TEXT NOT NULL, flag_state TEXT NOT NULL);
CREATE TABLE SavedSearchDBTable_Modified (id INTEGER PRIMARY KEY, search_id INTEGER NOT NULL, search_type TEXT NOT NULL, context TEXT NOT NULL, modified_state TEXT NOT NULL);
CREATE TABLE SavedSearchDBTable_Rating (id INTEGER PRIMARY KEY, search_id INTEGER NOT NULL, search_type TEXT NOT NULL, rating INTEGER NOT_NULL, context TEXT NOT NULL);
CREATE TABLE SavedSearchDBTable_Date (id INTEGER PRIMARY KEY, search_id INTEGER NOT NULL, search_type TEXT NOT NULL, context TEXT NOT NULL, date_one INTEGER NOT_NULL, date_two INTEGER NOT_NULL);
CREATE INDEX PhotoEventIDIndex ON PhotoTable (event_id);
CREATE INDEX SavedSearchDBTable_Text_Index ON SavedSearchDBTable_Text(search_id);
CREATE INDEX SavedSearchDBTable_MediaType_Index ON SavedSearchDBTable_MediaType(search_id);
CREATE INDEX SavedSearchDBTable_Flagged_Index ON SavedSearchDBTable_Flagged(search_id);
CREATE INDEX SavedSearchDBTable_Modified_Index ON SavedSearchDBTable_Modified(search_id);
CREATE INDEX SavedSearchDBTable_Rating_Index ON SavedSearchDBTable_Rating(search_id);
CREATE INDEX SavedSearchDBTable_Date_Index ON SavedSearchDBTable_Date(search_id);
CREATE TABLE FaceTable (id INTEGER NOT NULL PRIMARY KEY, name TEXT NOT NULL, time_created TIMESTAMP, ref INTEGER DEFAULT -1);
CREATE TABLE FaceLocationTable (id INTEGER NOT NULL PRIMARY KEY, face_id INTEGER NOT NULL, photo_id INTEGER NOT NULL, geometry TEXT, vec TEXT, guess INTEGER DEFAULT 0);
CREATE INDEX PhotoTableMD5FormatV2 on PhotoTable(md5, file_format);
CREATE INDEX PhotoTableThumbnailMD5Format on PhotoTable(thumbnail_md5, file_format);
CREATE INDEX PhotoTableThumbnailMD5MD5 on PhotoTable(thumbnail_md5, md5);
CREATE INDEX VideoEventIDIndex ON VideoTable (event_id);
