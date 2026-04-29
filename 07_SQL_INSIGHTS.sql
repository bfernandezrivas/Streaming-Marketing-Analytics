-- GENERAL OVERVIEW BY CONTENT
SELECT 
    content_type,
    COUNT(*) AS total_titles,
    ROUND(AVG(visibility_score), 2) AS avg_visibility,
    ROUND(AVG(engagement_score), 2) AS avg_engagement,
    ROUND(AVG(audience_reception_score), 2) AS avg_audience_reception,
    ROUND(AVG(business_value_score), 2) AS avg_business_value,
    ROUND(100.0 * SUM(hidden_gem) / COUNT(*), 2) AS pct_hidden_gems,
    ROUND(100.0 * SUM(tentpole_content) / COUNT(*), 2) AS pct_tentpole_content
FROM streaming_marketing_analytics.all_streaming_titles
GROUP BY content_type
ORDER BY avg_business_value DESC;

-- 2. TOP 10 TITLES WITH BIGEST BUSINESS VALUE 

SELECT 
    title,
    content_type,
    release_year,
    genre_names,
    original_language,
    visibility_score,
    engagement_score,
    audience_reception_score,
    business_value_score,
    marketing_segment
FROM streaming_marketing_analytics.all_streaming_titles
WHERE business_value_score IS NOT NULL
ORDER BY business_value_score DESC
LIMIT 20;

-- 3. Hidden Gems: GOOD ENGAGMENT BUT LOW VISIBILITY 

SELECT 
    title,
    content_type,
    release_year,
    genre_names,
    visibility_score,
    engagement_score,
    audience_reception_score,
    business_value_score,
    marketing_segment
FROM streaming_marketing_analytics.all_streaming_titles
WHERE hidden_gem = 1
ORDER BY engagement_score DESC, audience_reception_score DESC
LIMIT 20;

-- 4. TENTPOLE : ANCHOR TITLES FOR MARKETING STRATEGY 

SELECT 
    title,
    content_type,
    release_year,
    genre_names,
    popularity,
    vote_count,
    visibility_score,
    engagement_score,
    business_value_score
FROM streaming_marketing_analytics.all_streaming_titles
WHERE tentpole_content = 1
ORDER BY visibility_score DESC, business_value_score DESC
LIMIT 20;

-- 5. PERFORMANCE BY MARKETING SEGMENT 

SELECT 
    marketing_segment,
    COUNT(*) AS total_titles,
    ROUND(AVG(visibility_score), 2) AS avg_visibility,
    ROUND(AVG(engagement_score), 2) AS avg_engagement,
    ROUND(AVG(audience_reception_score), 2) AS avg_reception,
    ROUND(AVG(business_value_score), 2) AS avg_business_value
FROM streaming_marketing_analytics.all_streaming_titles
WHERE marketing_segment IS NOT NULL
GROUP BY marketing_segment
ORDER BY avg_business_value DESC;

-- GENRES WITH BEST BUSINESS POTENTIAL 

WITH exploded_genres AS (
    SELECT 
        TRIM(j.genre) AS genre,
        title,
        content_type,
        visibility_score,
        engagement_score,
        audience_reception_score,
        business_value_score
    FROM streaming_marketing_analytics.all_streaming_titles,
    JSON_TABLE(
        CONCAT(
            '["',
            REPLACE(genre_names, ',', '","'),
            '"]'
        ),
        '$[*]' COLUMNS (
            genre VARCHAR(255) PATH '$'
        )
    ) AS j
    WHERE genre_names IS NOT NULL
      AND genre_names <> ''
)

SELECT 
    genre,
    COUNT(*) AS total_titles,
    ROUND(AVG(visibility_score), 2) AS avg_visibility,
    ROUND(AVG(engagement_score), 2) AS avg_engagement,
    ROUND(AVG(audience_reception_score), 2) AS avg_reception,
    ROUND(AVG(business_value_score), 2) AS avg_business_value
FROM exploded_genres
GROUP BY genre
HAVING COUNT(*) >= 10
ORDER BY avg_business_value DESC;
 