-- Create dataset table
CREATE TABLE dataset (
    track_id VARCHAR(255) NOT NULL,
	artists VARCHAR(600),
	album_name VARCHAR(255),
	track_name VARCHAR(255),
	popularity INT,
	duration_ms INT,
	explicit BOOLEAN,
	danceability FLOAT,
	energy FLOAT,
	key INT,
	loudness FLOAT,
	mode INT,
	speechiness FLOAT,
	acousticness FLOAT,
    instrumentalness FLOAT,
	liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    time_signature INT,
	track_genre VARCHAR(255)
);


CREATE TABLE artist (
  artist_id SERIAL PRIMARY KEY,
  artist_name VARCHAR(255) NOT NULL UNIQUE
);


-- Create album table
CREATE TABLE album (
    album_id SERIAL PRIMARY KEY,
    album_name VARCHAR(255) NOT NULL,
    artist_id INT NOT NULL,
    FOREIGN KEY (artist_id) REFERENCES artist(artist_id)
);



-- Create track table
CREATE TABLE track (
    track_id VARCHAR(50) PRIMARY KEY,
    track_name VARCHAR(255) NOT NULL,
    duration INT,
    genre VARCHAR(100) NOT NULL,
    popularity INT,
    is_explicit VARCHAR(10),
    album_id INT NOT NULL,
    artist_id INT NOT NULL,
    FOREIGN KEY (album_id) REFERENCES album(album_id),
    FOREIGN KEY (artist_id) REFERENCES artist(artist_id)
);



-- Create track_details table
CREATE TABLE track_details (
    track_id VARCHAR(50) PRIMARY KEY,
    tempo FLOAT,
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    track_key INT,
    track_mode INT,
    time_signature INT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    FOREIGN KEY (track_id) REFERENCES track(track_id)
);

-- *********** INSERT STATEMENTS ***********


ALTER TABLE artist
ALTER COLUMN artist_name TYPE VARCHAR(500);

-- Insert into artist - Done
INSERT INTO artist (artist_name)
SELECT DISTINCT artists
FROM dataset
WHERE artists IS NOT NULL
ON CONFLICT (artist_name) DO NOTHING;




-- Insert into album - Done
INSERT INTO album (album_name, artist_id)
SELECT DISTINCT d.album_name, a.artist_id
FROM dataset d
JOIN artist a ON a.artist_name = d.artists
WHERE d.album_name IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM album al
    WHERE al.album_name = d.album_name AND al.artist_id = a.artist_id
);



-- Insert into track - Done
INSERT INTO track (
    track_id, track_name, duration, genre, popularity, is_explicit, album_id, artist_id
)
SELECT DISTINCT ON (d.track_id)
    d.track_id,
    d.track_name,
    d.duration_ms,
    d.track_genre,
    d.popularity,
    d.explicit,
    al.album_id,
    ar.artist_id
FROM dataset d
JOIN artist ar ON ar.artist_name = d.artists
JOIN album al ON al.album_name = d.album_name AND al.artist_id = ar.artist_id
ORDER BY d.track_id, d.popularity DESC  -- keep the most popular version
ON CONFLICT (track_id) DO UPDATE
SET
    track_name = EXCLUDED.track_name,
    duration = EXCLUDED.duration,
    genre = EXCLUDED.genre,
    popularity = EXCLUDED.popularity,
    is_explicit = EXCLUDED.is_explicit,
    album_id = EXCLUDED.album_id,
    artist_id = EXCLUDED.artist_id;




-- Insert into track_details
INSERT INTO track_details (
    track_id, tempo, danceability, energy, loudness, track_key, track_mode, time_signature,
    speechiness, acousticness, instrumentalness, liveness, valence
)
SELECT
    d.track_id,
    d.tempo,
    d.danceability,
    d.energy,
    d.loudness,
    d.key,
    d.mode,
    d.time_signature,
    d.speechiness,
    d.acousticness,
    d.instrumentalness,
    d.liveness,
    d.valence
FROM dataset d
WHERE EXISTS (
    SELECT 1 FROM track t WHERE t.track_id = d.track_id
)
ON CONFLICT (track_id) DO NOTHING;





-- \copy dataset FROM '/Users/dillonmavunga/Documents/Indiana U/Databases/FinalProjectDatabases/cleaned_spotify_ascii_only.csv' DELIMITER ',' CSV HEADER;

SELECT COUNT(DISTINCT track_id)
FROM track_details;

SELECT *
FROM artist
LIMIT 30;

