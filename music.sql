DROP DATABASE IF EXISTS music;
CREATE DATABASE music;
USE music;

CREATE TABLE genre (
	genre_name				VARCHAR(100)	PRIMARY KEY,
	genre_number_of_listeners		INT		NOT NULL
);

CREATE TABLE album (
    album_name			VARCHAR(100)	PRIMARY KEY,
    album_year			INT				NOT NULL,
    album_length		TIME			NOT NULL
);

CREATE TABLE song (
    song_name			VARCHAR(100)	PRIMARY KEY,
    song_year			INT				NOT NULL,
    song_length			TIME			NOT NULL,
    song_album			VARCHAR(100),	
    song_genre			VARCHAR(100)	NOT NULL,
    FOREIGN KEY (song_album) REFERENCES album(album_name) 
		ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (song_genre) REFERENCES genre(genre_name)
		ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE record_label (
    record_label_name				VARCHAR(100)	PRIMARY KEY,
    record_label_revenue			INT				NOT NULL,
    record_label_origin_country		VARCHAR(100)	NOT NULL
);

CREATE TABLE artist (
	artist_name				VARCHAR(100)	PRIMARY KEY,
    artist_country			VARCHAR(100)	NOT NULL,
    artist_age				INT				NOT NULL,
    artist_record_label		VARCHAR(100),
    FOREIGN KEY (artist_record_label) REFERENCES record_label(record_label_name)
		ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE sings (
	sings_artist	VARCHAR(100)	NOT NULL,
	sings_song		VARCHAR(100)	NOT NULL,
    PRIMARY KEY (sings_artist, sings_song),
    FOREIGN KEY (sings_artist) REFERENCES artist(artist_name)
		ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (sings_song) REFERENCES song(song_name)
		ON DELETE CASCADE ON UPDATE CASCADE
);

-- Trigger that updates album length after a song is inserted
DROP TRIGGER IF EXISTS insert_song_trigger ;
DELIMITER $$
CREATE TRIGGER insert_song_trigger AFTER INSERT ON song
FOR EACH ROW 
BEGIN
	UPDATE album
    SET album_length = 
		(SELECT SEC_TO_TIME(SUM(TIME_TO_SEC(song_length))) FROM song WHERE song.song_album = NEW.song_album)
    WHERE album.album_name = NEW.song_album;
END $$
DELIMITER ;

-- Trigger that updates album length after a song is updated
DROP TRIGGER IF EXISTS update_song_trigger;
DELIMITER $$
CREATE TRIGGER update_song_trigger AFTER UPDATE ON song
FOR EACH ROW 
BEGIN
	UPDATE album
    SET album_length = 
		(SELECT SEC_TO_TIME(SUM(TIME_TO_SEC(song_length))) FROM song WHERE song.song_album = NEW.song_album)
    WHERE album.album_name = NEW.song_album;
END $$
DELIMITER ;

-- Trigger that updates album length after a song is deleted
DROP TRIGGER IF EXISTS delete_song_trigger;
DELIMITER $$
CREATE TRIGGER delete_song_trigger AFTER DELETE ON song
FOR EACH ROW 
BEGIN
	UPDATE album
    SET album_length = 
		(SELECT SEC_TO_TIME(SUM(TIME_TO_SEC(song_length))) FROM song WHERE song.song_album = OLD.song_album)
    WHERE album.album_name = OLD.song_album;
END $$
DELIMITER ;

USE music;

-- add genre record
DROP PROCEDURE IF EXISTS add_genre;
DELIMITER $$
CREATE PROCEDURE add_genre
(IN name_input VARCHAR(100), IN listeners_input INT)
BEGIN
	INSERT INTO genre VALUES (name_input, listeners_input);
END$$
DELIMITER ;

-- add album record
DROP PROCEDURE IF EXISTS add_album;
DELIMITER $$
CREATE PROCEDURE add_album
(IN name_input VARCHAR(100), IN year_input INT, IN length_input TIME)
BEGIN
	INSERT INTO album VALUES (name_input, year_input, length_input);
END$$
DELIMITER ;

-- add song record
DROP PROCEDURE IF EXISTS add_song;
DELIMITER $$
CREATE PROCEDURE add_song
(IN name_input VARCHAR(100), IN year_input INT, IN length_input TIME, IN album_input VARCHAR(100), IN genre_input VARCHAR(100))
BEGIN
	INSERT INTO song VALUES (name_input, year_input, length_input, album_input, genre_input);
END$$
DELIMITER ;

-- add record_label record
DROP PROCEDURE IF EXISTS add_label;
DELIMITER $$
CREATE PROCEDURE add_label
(IN name_input VARCHAR(100), IN revenue_input INT, IN country_input VARCHAR(100))
BEGIN
	INSERT INTO record_label VALUES (name_input, revenue_input, country_input);
END$$
DELIMITER ;

-- add artist record
DROP PROCEDURE IF EXISTS add_artist;
DELIMITER $$
CREATE PROCEDURE add_artist
(IN name_input VARCHAR(100), IN country_input VARCHAR(100), IN age_input INT, IN record_label VARCHAR(100))
BEGIN
	INSERT INTO artist VALUES (name_input, country_input, age_input, record_label);
END$$
DELIMITER ;

-- add sings record
DROP PROCEDURE IF EXISTS add_sings;
DELIMITER $$
CREATE PROCEDURE add_sings
(IN artist_input VARCHAR(100), IN song_input VARCHAR(100))
BEGIN
	INSERT INTO sings VALUES (artist_input, song_input);
END$$
DELIMITER ;

-- delete a genre record with genre name
DROP PROCEDURE IF EXISTS delete_genre;
DELIMITER $$
CREATE PROCEDURE delete_genre
(IN name_input VARCHAR(100))
BEGIN
	DELETE FROM genre WHERE genre_name = name_input;
END$$
DELIMITER ;

-- delete a album record with album name
DROP PROCEDURE IF EXISTS delete_album;
DELIMITER $$
CREATE PROCEDURE delete_album
(IN name_input VARCHAR(100))
BEGIN
	DELETE FROM album WHERE album_name = name_input;
END$$
DELIMITER ;

-- delete a song record with song name
DROP PROCEDURE IF EXISTS delete_song;
DELIMITER $$
CREATE PROCEDURE delete_song
(IN name_input VARCHAR(100))
BEGIN
	DELETE FROM song WHERE song_name = name_input;
END$$
DELIMITER ;

-- delete a record_label record with record_label name
DROP PROCEDURE IF EXISTS delete_label;
DELIMITER $$
CREATE PROCEDURE delete_label
(IN name_input VARCHAR(100))
BEGIN
	DELETE FROM record_label WHERE record_label_name = name_input;
END$$
DELIMITER ;

-- delete a artist record with artist name
DROP PROCEDURE IF EXISTS delete_artist;
DELIMITER $$
CREATE PROCEDURE delete_artist
(IN name_input VARCHAR(100))
BEGIN
	DELETE FROM artist WHERE artist_name = name_input;
END$$
DELIMITER ;

-- deletes a sings record with an artist name and a song name
DROP PROCEDURE IF EXISTS delete_sings;
DELIMITER $$
CREATE PROCEDURE delete_sings
(IN artist_input VARCHAR(100), song_input VARCHAR(100))
BEGIN
	DELETE FROM sings WHERE sings_artist = artist_input AND sings_song = song_input;
END$$
DELIMITER ;

-- update a genre record with field name and new field
DROP PROCEDURE IF EXISTS update_genre;
DELIMITER $$
CREATE PROCEDURE update_genre
(IN name_input VARCHAR(100), field_name VARCHAR(100), new_field VARCHAR(100))
BEGIN
	SET @name_input = name_input;
    SET @new_field = new_field;
	SET @s = CONCAT('UPDATE genre SET ', field_name, ' = ? WHERE genre_name = ?');
	PREPARE stmt FROM @s;
	EXECUTE stmt USING @new_field, @name_input;
	DEALLOCATE PREPARE stmt;
END$$
DELIMITER ;

-- update a album record with field name and new field
DROP PROCEDURE IF EXISTS update_album;
DELIMITER $$
CREATE PROCEDURE update_album
(IN name_input VARCHAR(100), field_name VARCHAR(100), new_field VARCHAR(100))
BEGIN
	SET @name_input = name_input;
    SET @new_field = new_field;
	SET @s = CONCAT('UPDATE album SET ', field_name, ' = ? WHERE album_name = ?');
	PREPARE stmt FROM @s;
	EXECUTE stmt USING @new_field, @name_input;
	DEALLOCATE PREPARE stmt;
END$$
DELIMITER ;

-- update a song record with field name and new field
DROP PROCEDURE IF EXISTS update_song;
DELIMITER $$
CREATE PROCEDURE update_song
(IN name_input VARCHAR(100), field_name VARCHAR(100), new_field VARCHAR(100))
BEGIN
	SET @name_input = name_input;
    SET @new_field = new_field;
	SET @s = CONCAT('UPDATE song SET ', field_name, ' = ? WHERE song_name = ?');
	PREPARE stmt FROM @s;
	EXECUTE stmt USING @new_field, @name_input;
	DEALLOCATE PREPARE stmt;
END$$
DELIMITER ;

-- update a record label record with field name and new field
DROP PROCEDURE IF EXISTS update_label;
DELIMITER $$
CREATE PROCEDURE update_label
(IN name_input VARCHAR(100), field_name VARCHAR(100), new_field VARCHAR(100))
BEGIN
	SET @name_input = name_input;
    SET @new_field = new_field;
	SET @s = CONCAT('UPDATE record_label SET ', field_name, ' = ? WHERE record_label_name = ?');
	PREPARE stmt FROM @s;
	EXECUTE stmt USING @new_field, @name_input;
	DEALLOCATE PREPARE stmt;
END$$
DELIMITER ;

-- update a artist record with field name and new field
DROP PROCEDURE IF EXISTS update_artist;
DELIMITER $$
CREATE PROCEDURE update_artist
(IN name_input VARCHAR(100), field_name VARCHAR(100), new_field VARCHAR(100))
BEGIN
	SET @name_input = name_input;
    SET @new_field = new_field;
	SET @s = CONCAT('UPDATE artist SET ', field_name, ' = ? WHERE artist_name = ?');
	PREPARE stmt FROM @s;
	EXECUTE stmt USING @new_field, @name_input;
	DEALLOCATE PREPARE stmt;
END$$
DELIMITER ;

-- update a sings record with field name and new field
DROP PROCEDURE IF EXISTS update_sings;
DELIMITER $$
CREATE PROCEDURE update_sings
(IN artist_input VARCHAR(100), song_input VARCHAR(100), field_name VARCHAR(100), new_field VARCHAR(100))
BEGIN
	SET @artist_input = artist_input;
    SET @song_input = song_input;
    SET @new_field = new_field;
	SET @s = CONCAT('UPDATE sings SET ', field_name, ' = ? WHERE sings_artist = ? AND sings_song = ?');
	PREPARE stmt FROM @s;
	EXECUTE stmt USING @new_field, @artist_input, @song_input;
	DEALLOCATE PREPARE stmt;
END$$
DELIMITER ;

-- select all with table name, ordering field, and direction of order
DROP PROCEDURE IF EXISTS select_all;
DELIMITER $$
CREATE PROCEDURE select_all
(IN table_input VARCHAR(100), IN order_field VARCHAR(100), IN direction VARCHAR(100))
BEGIN
    SET @s = CONCAT('SELECT * FROM ', table_input, ' ORDER BY ', order_field, ' ', direction);
	PREPARE stmt FROM @s;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END$$
DELIMITER ;

-- select song with ordering field and direction of order
DROP PROCEDURE IF EXISTS select_song;
DELIMITER $$
CREATE PROCEDURE select_song
(IN order_field VARCHAR(100), IN direction VARCHAR(100))
BEGIN
	SET @s = CONCAT(
    'SELECT song_name, song_year, song_length, song_album, song_genre, GROUP_CONCAT(artist_name) AS artists 
    FROM song 
    JOIN sings ON song.song_name = sings.sings_song 
    JOIN artist ON sings.sings_artist = artist.artist_name 
    GROUP BY song_name 
    ORDER BY ', order_field, ' ', direction);
    PREPARE stmt FROM @s;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END$$
DELIMITER ;

-- select songs with album name
DROP PROCEDURE IF EXISTS select_album_songs;
DELIMITER $$
CREATE PROCEDURE select_album_songs
(IN album_input VARCHAR(100))
BEGIN
	SET @album_input = album_input;
	SET @s = 
    'SELECT song_name, song_year, song_length, song_album, song_genre, GROUP_CONCAT(artist_name) AS artists 
    FROM song 
    JOIN sings ON song.song_name = sings.sings_song 
    JOIN artist ON sings.sings_artist = artist.artist_name 
    JOIN album ON song.song_album = album.album_name 
    WHERE album_name = ? 
    GROUP BY song_name';
    PREPARE stmt FROM @s;
    EXECUTE stmt USING @album_input;
    DEALLOCATE PREPARE stmt;
END$$
DELIMITER ;

-- select songs with genre name
DROP PROCEDURE IF EXISTS select_genre_songs;
DELIMITER $$
CREATE PROCEDURE select_genre_songs
(IN genre_input VARCHAR(100))
BEGIN
	SET @genre_input = genre_input;
	SET @s = 
    'SELECT song_name, song_year, song_length, song_album, song_genre, GROUP_CONCAT(artist_name) AS artists 
    FROM song 
    JOIN sings ON song.song_name = sings.sings_song 
    JOIN artist ON sings.sings_artist = artist.artist_name 
    JOIN genre ON song.song_genre = genre.genre_name 
    WHERE genre_name = ? 
    GROUP BY song_name';
    PREPARE stmt FROM @s;
    EXECUTE stmt USING @genre_input;
    DEALLOCATE PREPARE stmt;
END$$
DELIMITER ;

-- select songs with artist name
DROP PROCEDURE IF EXISTS select_artist_songs;
DELIMITER $$
CREATE PROCEDURE select_artist_songs
(IN artist_input VARCHAR(100))
BEGIN
	SET @artist_input = artist_input;
	SET @s = CONCAT(
    'SELECT * FROM 
		(SELECT song_name, song_year, song_length, song_album, song_genre, GROUP_CONCAT(artist_name) AS artists 
		FROM song 
		JOIN sings ON song.song_name = sings.sings_song 
		JOIN artist ON sings.sings_artist = artist.artist_name 
		GROUP BY song_name) AS t1
	WHERE artists LIKE ''%', artist_input, '%''');
    PREPARE stmt FROM @s;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END$$
DELIMITER ;

-- gets the types of the columns of the table
DROP PROCEDURE IF EXISTS get_type;
DELIMITER $$
CREATE PROCEDURE get_type
(IN table_input VARCHAR(100))
BEGIN
	SELECT DATA_TYPE
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE table_name = table_input;
END$$
DELIMITER ;

-- gets the names of the colums of the table
DROP PROCEDURE IF EXISTS get_columns;
DELIMITER $$
CREATE PROCEDURE get_columns
(IN table_input VARCHAR(100))
BEGIN
	SELECT COLUMN_NAME 
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE table_name = table_input;
END$$
DELIMITER ;

INSERT INTO genre VALUES
('hip-hop', 156),
('rock', 132),
('pop', 81),
('country', 49),
('latin', 38),
('electronic', 22),
('jazz', 6),
('classical', 6);

INSERT INTO album VALUES
('DAMN.', 2017, '00:00:00'),
('Melodrama', 2017, '00:00:00'),
('Everybody', 2017, '00:00:00'),
('1989', 2014, '00:00:00'),
('Life Changes', 2017, '00:00:00'),
('Abbey Road', 1969, '00:00:00'),
('The Aviary', 2017, '00:00:00');

INSERT INTO song VALUES
('DNA.', 2017, '00:03:06', 'DAMN.', 'hip-hop'),
('ELEMENT.', 2017, '00:03:29', 'DAMN.', 'hip-hop'),
('FEEL.', 2017, '00:03:35', 'DAMN.', 'hip-hop'),
('LOYALTY.', 2017, '00:03:47', 'DAMN.', 'hip-hop'),
('HUMBLE.', 2017, '00:02:57', 'DAMN.', 'hip-hop'),
('LOVE.', 2017, '00:03:33', 'DAMN.', 'hip-hop'),
('Green Light', 2017, '00:03:55', 'Melodrama', 'pop'),
('Sober', 2017, '00:03:17', 'Melodrama', 'pop'),
('Homemade Dynamite', 2017, '00:03:10', 'Melodrama', 'pop'),
('Liability', 2017, '00:02:52', 'Melodrama', 'pop'),
('Hallelujah', 2017, '00:07:29', 'Everybody', 'hip-hop'),
('Everybody', 2017, '00:02:42', 'Everybody', 'hip-hop'),
('Mos Definitely', 2017, '00:03:26', 'Everybody', 'hip-hop'),
('1-800-272-8255', 2017, '00:04:10', 'Everybody', 'hip-hop'),
('Anziety', 2017, '00:06:53', 'Everybody', 'hip-hop'),
('Welcome to New York', 2014, '00:03:33', '1989', 'pop'),
('Blank Space', 2014, '00:03:52', '1989', 'pop'),
('Shake It Off', 2014, '00:03:39', '1989', 'pop'),
('Bad Blood', 2014, '00:03:32', '1989', 'pop'),
('Wildest Dreams', 2014, '00:03:40', '1989', 'pop'),
('How You Get The Girl', 2014, '00:04:08', '1989', 'pop'),
('Craving You', 2017, '00:03:44', 'Life Changes', 'country'),
('Unforgettable', 2017, '00:02:37', 'Life Changes', 'country'),
('Sixteen', 2017, '00:02:58', 'Life Changes', 'country'),
('Marry Me', 2017, '00:03:25', 'Life Changes', 'country'),
('Come Together', 1969, '00:04:20', 'Abbey Road', 'rock'),
('Something', 1969, '00:03:02', 'Abbey Road', 'rock'),
('I Want You', 1969, '00:07:47', 'Abbey Road', 'rock'),
('Here Comes The Sun', 1969, '00:03:06', 'Abbey Road', 'rock'),
('Hey Alligator', 2017, '00:03:29', 'The Aviary', 'electronic'),
('Girls On Boys', 2017, '00:03:00', 'The Aviary', 'electronic'),
('Tell Me You Love Me', 2017, '00:03:10', 'The Aviary', 'electronic'),
('Hunter', 2017, '00:03:03', 'The Aviary', 'electronic'),
('Love On Me', 2017, '00:03:25', 'The Aviary', 'electronic'),
('No Money', 2017, '00:03:11', 'The Aviary', 'electronic'),
('Closer', 2016, '00:04:05', NULL, 'pop'),
('Roses', 2015, '00:03:47', NULL, 'pop'),
('Don''t Let Me Down', 2016, '00:03:28', NULL, 'pop'),
('Something Just Like This', 2017, '00:04:08', NULL, 'pop');


INSERT INTO record_label VALUES
('Top Dawg Entertainment', 125, 'United States'),
('Universal Music Group', 150, 'United States'),
('Def Jam Recordings', 180, 'United States'),
('Big Machine Records', 130, 'United States'),
('Big Beat Records', 78, 'United States'),
('Sony Music Entertainment', 85, 'United States'),
('RCA Records', 50, 'United States'),
('Parlophone', 70, 'Germany');

INSERT INTO artist VALUES
('Kendrick Lamar', 'United States', 30, 'Top Dawg Entertainment'),
('Lorde', 'New Zealand', 21, 'Universal Music Group'),
('Logic', 'United States', 28, 'Def Jam Recordings'),
('Taylor Swift', 'United States', 28, 'Big Machine Records'),
('Thomas Rhett', 'United States', 28, 'Big Machine Records'),
('The Beatles', 'United States', 58, NULL),
('Galantis', 'Sweden', 6, 'Big Beat Records'),
('The Chainsmokers', 'United States', 6, 'Sony Music Entertainment'),
('Rihanna', 'Barbados', 30, 'Def Jam Recordings'),
('Alessia Cara', 'Canada', 21, 'Def Jam Recordings'),
('Khalid', 'United States', 20, 'RCA Records'),
('Coldplay', 'United Kingdom', 22, 'Parlophone');

INSERT INTO sings VALUES
('Kendrick Lamar', 'DNA.'),
('Kendrick Lamar', 'ELEMENT.'),
('Kendrick Lamar', 'FEEL.'),
('Kendrick Lamar', 'LOYALTY.'),
('Rihanna', 'LOYALTY.'),
('Kendrick Lamar', 'HUMBLE.'),
('Kendrick Lamar', 'LOVE.'),
('Lorde', 'Green Light'),
('Lorde', 'Sober'),
('Lorde', 'Homemade Dynamite'),
('Lorde', 'Liability'),
('Lorde', 'Hallelujah'),
('Logic', 'Everybody'),
('Lorde', 'Mos Definitely'),
('Logic', '1-800-272-8255'),
('Alessia Cara', '1-800-272-8255'),
('Khalid', '1-800-272-8255'),
('Logic', 'Anziety'),
('Taylor Swift', 'Welcome to New York'),
('Taylor Swift', 'Blank Space'),
('Taylor Swift', 'Shake It Off'),
('Taylor Swift', 'Bad Blood'),
('Kendrick Lamar', 'Bad Blood'),
('Taylor Swift', 'Wildest Dreams'),
('Taylor Swift', 'How You Get The Girl'),
('Thomas Rhett', 'Craving You'),
('Thomas Rhett', 'Unforgettable'),
('Thomas Rhett', 'Sixteen'),
('Thomas Rhett', 'Marry Me'),
('The Beatles', 'Come Together'),
('The Beatles', 'Something'),
('The Beatles', 'I Want You'),
('The Beatles', 'Here Comes The Sun'),
('Galantis', 'Hey Alligator'),
('Galantis', 'Girls On Boys'),
('Galantis', 'Tell Me You Love Me'),
('Galantis', 'Hunter'),
('Galantis', 'Love On Me'),
('Galantis', 'No Money'),
('The Chainsmokers', 'Closer'),
('The Chainsmokers', 'Roses'),
('The Chainsmokers', 'Don''t Let Me Down'),
('The Chainsmokers', 'Something Just Like This'),
('Coldplay', 'Something Just Like This');
