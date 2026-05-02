# Streaming-Marketing-Analytics
Visibility, Engagement & Business Value
------- 
# 🚀 Overview
The streaming industry relies heavily on content performance to drive user acquisition, engagement, and retention. However, key business metrics such as revenue, watch time, or retention are not publicly available.
This project addresses that limitation by transforming publicly available content data into actionable marketing insights.

The goal is to build a data-driven framework that estimates:

- Visibility (discoverability)
- Engagement (audience interaction)
- Audience reception (perceived quality)
- Business Value (estimated commercial potential)

The project combines data analysis, feature engineering, and machine learning to support content marketing and strategy decisions.

------- 
# 🎯 Business Objective
- This project aims to answer key marketing questions:
- Which content has the highest commercial potential?
- What characteristics drive visibility and engagement?
- Are there hidden gems (low visibility, high engagement)?
- How can we identify high-value content segments?
The output is an interactive dashboard + recommendation tool that supports:
- Content prioritization
- Marketing investment decisions
- Content positioning strategies

-------
# 🧠 Key Features
📈 1. Marketing Performance Framework

Custom metrics built from public data:
- Visibility Score → based on popularity
- Engagement Score → based on vote count
- Audience Reception Score → based on ratings
- Business Value Score → weighted combination

Business Value Formula:
40% Visibility
30% Engagement
20% Audience Reception
10% Recency

🔍 2. Exploratory Data Analysis (EDA)
- Distribution analysis (popularity, votes, ratings)
- Genre and language performance
- Movie vs TV comparison
- Time trends
- Visibility vs engagement relationships

🧩 3. Content Segmentation
Strategic classification:
| Segment         | Description                       |
| --------------- | --------------------------------- |
| 🎬 Tentpole     | High visibility + high engagement |
| 💎 Hidden gems  | Low visibility + high engagement  |
| ⚠️ Overexposed  | High visibility + low engagement  |
| 📉 Low priority | Low visibility + low engagement   |


🤖 4. Recommendation System (ML)
A similarity-based model using content descriptions (synopsis):
- Identifies similar titles
- Associates them with Business Value potential
- Supports content recommendation and positioning
This moves the project from analysis → actionable recommendations

📊 5. Interactive Dashboard (Streamlit)
Main features:
- Global KPIs overview
- Visibility analysis
- Engagement analysis
- Business Value segmentation
- Time evolution
- Content comparison

-------
# 🗂️ Data Sources
Primary APIs:
- TMDb (The Movie Database)
- TVMaze
Data includes:
- Title / content type
- Popularity
- Vote count
- Vote average
- Genres
- Language
- Release date
- Synopsis

------
# ⚙️ Tech Stack
- Python
- - pandas, numpy
- - requests
- - scikit-learn
- Visualization
- - matplotlib / plotly
- Dashboard
- - Streamlit
- Version Control
- - GitHub

------ 
# 🔄 Data Pipeline
1. Data Extraction
- - API calls (TMDb, TVMaze)
2. Data Cleaning
- - Missing values
- - Standardization
- - Deduplication
3. EDA
- - Statistical analysis
- - Visualization
4. Feature Engineering
- - Creation of scores
- - Time variables
- - Content categorization
5. Modeling
- - Similarity-based recommendation
6. Visualization
- - Streamlit dashboard

------
# 📌 Key Insights
- High visibility does not guarantee high engagement
- Some content shows strong engagement despite low exposure (hidden gems)
- TV shows and movies exhibit different performance patterns
- Genre and language significantly impact performance
- Business value is driven by a combination of factors, not a single metric
-----
# ⚠️ Limitations
- Uses proxy metrics, not real revenue data
- Does not account for platform-specific algorithms
- Dependent on API data quality
-----
# 🔮 Future Improvements
- Improve recommendation model (NLP / embeddings)
- Add qualitative features (themes, topics)
- Integrate more data sources
- Validate model with real business data
-----
# 🔐 Data & Compliance
- Uses publicly available data only
- No personal or sensitive data
- Fully compliant with GDPR principles

----
# 👩‍💻 Author
Blanca Fernandez Rivas
-----
# ⭐ Final Note
This project demonstrates how public data can be transformed into strategic marketing insights, bridging the gap between data availability and business decision-making.

