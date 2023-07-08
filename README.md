# My311 City Services Tableau Dashboard using SQL

### Purpose
- The project focused on identifying the most common types of service requests, analyzing usage patterns across different areas, examining trends over time, and investigating anonymous request preferences.

![](https://i.postimg.cc/VLjMMM2c/dash2.png)
- *Tableau link: [Here](https://public.tableau.com/app/profile/mariela.lopez/viz/my311_16806664034940/Dashboard1)*

### Objective
- The project aimed to showcase data analysis skills using SQL and address questions in a real-world scenario. 
- This data would then be consolidated and presented in an interactive Tableau Dashboard for a respective operations team or city agency that would need consolidated data on hand. 

---

### Data Understanding
- The project utilized two main data sources: the latest Census data of Los Angeles County and My311 services data for FY22. 
- The raw data was imported into PostgreSQL, and necessary data cleaning steps were performed. This included changing data types, filling in missing values, and extracting relevant information for improved readability. 
- The data exploration phase involved using SQL queries with group by, aggregate, and partitioning functionality to investigate various aspects of the 311 service.

![](https://i.postimg.cc/c4mC0cV6/extractingdata.png)
- *Part of the data cleaning process, extracting data from an existing columns for improved use. Here it was extracting the time from the full timestamp to make use of the date.*

![](https://i.postimg.cc/DwwZZXT6/investigating-population-density.png)
- *Investigating the Census data set to create a population density column for later analysis.*

![](https://i.postimg.cc/y8pNS86H/most-used-service.png)
- *Query shows in descending order the most used services within the 311 data.*

![](https://i.postimg.cc/ydc65hm1/my311-with-population-density.png)
- *Query shows the association between number of 311 service requests per neighborhood and respective population density. Most services tend to occur in heavily populated neighborhoods.*

### Evaluation
- No modeling was performed in this project. The analysis was carried out using PostgreSQL, leveraging the power of SQL queries. 
- Various queries were employed to address the problem questions, including grouping, aggregating, and  CASE statements to represent data in different formats. 
- By leveraging Tableau for visualization, I could identify and address questions in the data, such as the following outcomes: 
    1. *The most used service for 311 all throughout FY22 was Bulky Items with 136,310 requests.*
    2. *Roughly 50% of the requests made (across all services) were made by the department of LA Sanitation.* 
    3. *Based on a geo-map using latitude and longitude mapping, Central Los Angeles (zipcode 90011) had the most requests across the county with 41,511 requests in FY22. The most used service in that area was Graffiti Removal.*
    4. *It takes around 5.49 days to resolve a case in the city.*
    5. *Over time, 311 tends to be busiest either at the start of the year or during early summer months. With requests drastically dropping by year end.*
    6. *Overall, the general public and other agencies that report requests to 311 do not have a strong preference for anonimity with 92.84% not being anonimous.* 
    7. *The majority of requests come in via call (at 54.40%), followed by Mobile app (at 29.84%)*

---

### Conclusion
- This project successfully demonstrates the application of data analysis skills using SQL to explore and analyze the 311 service in Los Angeles County. By addressing problem questions related to service usage, geographical patterns, trends over time, and anonymous requests, valuable insights were obtained. The resulting Tableau dashboard presents the findings in an interactive and visually appealing manner, providing a comprehensive overview of the 311 service and supporting informed decision-making.

- Among the types of decisions that can be made with this data include: 
    1. Where to allocate more or less 311 resources based on usage and neighborhood demand.
    2. Which department/agency is leveraged most often to decide proper funding and future planning.
    3. Deciding how to prepare for peak traffic volumes at different times of the year. 
    4. Deciding what public tools for 311 service can be prioritized based on usage/demand. 
    
- Some next steps I would consider: 
    - Conduct further analysis on specific service request types, exploring correlations with demographic data, temporal patterns, or predictive modeling.
    - Engage with stakeholders by sharing the Tableau dashboard and project findings, seeking feedback to refine the analysis and improve understanding.
    - Regularly update the dataset to track service pattern evolution over time and identify emerging trends or shifts in demand.
    - Explore collaboration opportunities with other data analysts or researchers working on similar projects.
    - Monitor the impact of decisions or actions taken based on project findings through impact assessments.

#### Credit
- [My311 Los Angeles FY22](https://data.lacity.org/City-Infrastructure-Service-Requests/MyLA311-Service-Request-Data-2022/i5ke-k6by) Public data sourced from lacity.org 
- [Los Angeles County Census Data](https://data.lacounty.gov/datasets/lacounty::census-blocks-2020/explore?location=34.161823%2C-118.370868%2C16.27&showTable=true) Public data sourced from lacity.org
- [LA County Zipcodes](https://www.laalmanac.com/communications/cm02_communities.php) Public data sourced from Los Angeles Almanac
