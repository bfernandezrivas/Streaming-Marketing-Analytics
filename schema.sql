-- ============================================================
-- Streaming Marketing Analytics — Physical data model (Merise) v2
-- Target DBMS: MySQL 8.x
-- Updated to reflect the real second source: IMDb official flat
-- files (title.basics / title.principals / title.crew / name.basics),
-- enriching content with cast, directors and cinematographers.
--
-- GDPR note: cast/crew names are public credit information published
-- by IMDb (professional attribution, not personal/sensitive data),
-- not user data. No personal data about the application's end users
-- is collected or processed.
-- ============================================================

DROP DATABASE IF EXISTS streaming_marketing;
CREATE DATABASE streaming_marketing CHARACTER SET utf8mb4;
USE streaming_marketing;

-- Dimension table: languages
CREATE TABLE LANGUAGE_TABLE (
    id_language     INT AUTO_INCREMENT PRIMARY KEY,
    language_code   VARCHAR(10) NOT NULL UNIQUE,
    language_name   VARCHAR(100)
);

-- Dimension table: genres
CREATE TABLE GENRE (
    id_genre       INT AUTO_INCREMENT PRIMARY KEY,
    genre_name     VARCHAR(100) NOT NULL UNIQUE
);

-- Central entity: content (movies / TV shows) — source = API (TMDb/TVMaze)
CREATE TABLE CONTENT (
    id_content       INT AUTO_INCREMENT PRIMARY KEY,
    title            VARCHAR(255) NOT NULL,
    original_title   VARCHAR(255),
    content_type     ENUM('movie', 'tv') NOT NULL,
    id_language      INT,
    release_year     SMALLINT,
    popularity       FLOAT,
    vote_average     FLOAT,
    vote_count       INT,
    overview         TEXT,
    imdb_id          VARCHAR(20),               -- resolved via the IMDb data-file matching step
    imdb_match_status VARCHAR(50),              -- traceability: how the imdb_id was resolved
    adult            BOOLEAN DEFAULT FALSE,
    source_origin    VARCHAR(50) DEFAULT 'TMDb/TVMaze API',
    extraction_date  DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_language) REFERENCES LANGUAGE_TABLE(id_language),
    INDEX idx_imdb_id (imdb_id)
);

-- N:N association between content and genres
CREATE TABLE CONTENT_GENRE (
    id_content   INT NOT NULL,
    id_genre     INT NOT NULL,
    PRIMARY KEY (id_content, id_genre),
    FOREIGN KEY (id_content) REFERENCES CONTENT(id_content) ON DELETE CASCADE,
    FOREIGN KEY (id_genre) REFERENCES GENRE(id_genre) ON DELETE CASCADE
);

-- Derived metrics (feature engineering — C3)
CREATE TABLE SCORE (
    id_content            INT PRIMARY KEY,
    visibility_score       FLOAT,
    engagement_score        FLOAT,
    reception_score        FLOAT,
    business_value_score   FLOAT,
    calculation_date        DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_content) REFERENCES CONTENT(id_content) ON DELETE CASCADE
);

-- People (cast, directors, cinematographers) — comes from the SECOND SOURCE
-- (IMDb official flat files: title.principals / title.crew / name.basics)
-- Supports C1: mix of API (service web) + data file (fichier de données)
CREATE TABLE PERSON (
    id_person      INT AUTO_INCREMENT PRIMARY KEY,
    full_name      VARCHAR(255) NOT NULL,
    imdb_nconst    VARCHAR(20) UNIQUE,
    UNIQUE KEY uq_person_name (full_name)
);

-- N:N association between content and people, with their role on that title
CREATE TABLE CONTENT_PERSON (
    id_content   INT NOT NULL,
    id_person    INT NOT NULL,
    role         ENUM('cast', 'director', 'cinematographer') NOT NULL,
    ordering     SMALLINT,
    PRIMARY KEY (id_content, id_person, role),
    FOREIGN KEY (id_content) REFERENCES CONTENT(id_content) ON DELETE CASCADE,
    FOREIGN KEY (id_person) REFERENCES PERSON(id_person) ON DELETE CASCADE
);
