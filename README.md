# Stats 220 Final Project

My Shiny app allows us to explore how economic conditions vary from state to state, and over time. [Link to Shiny app](https://isabella-cha.shinyapps.io/finalproject-chaisabella/)

## In this repo, you can find:

-   **data**: contains my raw data files (in Excel format). There are 4 data files in this folder. The file names are fairly self explanatory: **gdp_by_state.xlsx** (GDP by state), **percap_income_by_state.xlsx** (per capita income by state), **personal_income_state_xlsx** (personal income by state), **population_by_state.xlsx** (population level by state).
-   **app.R**: the final product (Shiny app)! Here, you can find all the code, methods/processes used to create my Shiny App, including the data wrangling, user interface, and server functions.
-   **about.md**: a brief description about the purpose of my Shiny app, as well as some background information on the topic (for example, why do we care about GDP and income?)
-   **references.md**: contains citations for data sources
-   **finalproject.Rmd**: you can ignore this file. It's essentially the same content as app.R, but I used this Rmd file for debugging purposes (it's asier to run individual R chunks when debugging, as oppposed to running a whole app).


## Technical Report
### Data Wrangling:
I had four separate raw data files that I combined into one dataset for my Shiny app. Merging the datasets involved using complex data wrangling skills. I dealt with NA values, pivoted the data into a longer format, used mutate statements to harmonize column types, and merged datasets together using inner join statements. 

Example workflow: 
The raw data file **personal_income_state.xlsx** initially had 52 rows and 26 total columns. I removed the first column because it was not relevant. Then, I ran into a problem because the NA values were expressed as a character string rather than an actual null value, so I converted these into a NA type. I also detected a problem that the column types for income values were inconsistent (some were character types, others were numeric types). I used a the "mutate" and "across" functions to harmonize column types. Afterwards, I was able to convert the data into a longer format using "pivot_longer". 

I followed a similar process for each dataset, and merged them at the end with a join statement. In addition, I manually added a column for GDP per capita using the GDP and population data. Note, GDP data was expressed in millions of dollars, which I took into account when calculating GDP per capital. 


### Creating the Shiny App
My goal was to create an app that could visualize the different growth paths among the different states. My app has a button where the user can choose an economic indicator (such as GDP, GDP per capita, etc.), and two drop-down menu options where they can choose the two regions for comparison. The user can also specify a time frame using a slider. From this user input, the app displays a connected scatterplot of the economic trajectory of the selected regions. 

Creating this app involved learning more advanced Shiny skills. I learned how to create reactive radio buttons, which was not something we covered in class. I also became more comfortable with reactive functions, as my graph needed to be updated based on the user input. In particular, I learned how to render a ggplot object based on variable input from radio buttons.

One really cool feature of my app is that I have a reactive heading! For example, if the user selects regions "Wisconsin", "Alaska", and the years 2003-2011, the heading will be updated to display: "Wisconsin and Alaska , 2003 - 2011". How awesome is that! 

I also applied my previous knowledge of html to make my app more easily navigable. There is a top-level navigation bar that allows the user to navigate between the tool itself, an "About" page, and a "Data" page for the data sources. 

References I used for learning new tools: 
* Radio Buttons: https://shiny.rstudio.com/reference/shiny/1.7.0/radiobuttons
* Navigation bar page: https://shiny.rstudio.com/reference/shiny/1.0.5/navbarpage
* Reactive ggplot: https://community.rstudio.com/t/shiny-reactive-data-plotting-using-ggplot/75390/2











