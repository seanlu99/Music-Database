# Music Database

This project is a music database that includes entities for songs, albums, genres, artists, and record labels. The project includes a command-line interface, providing functionalities for the database such as adding and deleting data, updating values, sorting by an attribute, and a variety of querying. An in-depth diagram of the relationships between entities is shown in "UML Diagram.jpg," the attributes of the entities is shown in "EER Model.png," and the complete flow of user functionality is shown in "User Flow Diagram.jpg."

## Prerequisites
1. Download latest version of Java from https://java.com/en/download/
2. Download MySQL from https://dev.mysql.com/downloads/mysql/
3. Download JDBC driver from https://dev.mysql.com/downloads/connector/j/ to any JDBC_PATH

## Installing
1. Download the file “Song.class” to any FRONT_END_PATH for the front end code
2. Download file “music.sql” to anywhere for the back end code

## Option 1: Setup through terminal
1. Start MySQL server
2. Open music.sql in MySQL and run the file
3. Open terminal
4. Type “export CLASSPATH="FRONT_END_PATH/Database/src/:/JDBC_PATH/JDBC_FILENAME""
5. Type “cd FRONT_END_PATH/Database/src/music”
6. Type “javac Song.java”
7. Type “cd ..”
8. Type “java music.Song”

## Option 2: Setup through Eclipse
1. Start MySQL server
2. Open music.sql in MySQL and run the file
3. Download the latest version of Eclipse from http://www.eclipse.org/downloads/
4. Move the “Database” folder to any ECLIPSE_WORKSPACE
5. Open Eclipse with ECLIPSE_WORKSPACE
6. Click Database -> src -> Song.java
7. Right click Database -> Build Path -> Configure Build Path -> Add External JARs -> JDBC_PATH/JDBC_FILENAME
8. Run “Song.java”

## Login credentials for admin
Username: admin
Password: password
