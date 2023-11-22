## Scraping CBK Data

library(tidyverse) ## data handling package
library(rvest)     ## web scraping package
library(janitor)   ## data processing/cleaning package

url <- "https://bqk-kos.org/statistics/time-series/?lang=en" # supplying the URL of the website that will be scraped
  
bqk_xpath <- "/html/body/div[3]/div/div[2]/div/div[1]/figure[1]/table" # supplying the specific xpath of the elements that need to be scraped. In this case it's the table.

### Scraping the Table
page <- read_html(url)
df <- page |> 
  html_element(xpath = bqk_xpath) |> 
  html_table() # scraping the table

df <- df |> 
  clean_names() |> 
  filter(latest_data != "",
         latest_data != "Not available") |> 
  mutate(latest_data = str_squish(latest_data)) # processing the table

# The links however aren't automatically scraped by the table, so we get them separately.

links <- page |> 
  html_elements("td") |> 
  html_elements("a") |> 
  html_attr("href")
links

text <- page |> 
  html_elements("td") |> 
  html_elements("a") |> 
  html_text2()
text

# Then we combine the original table with the links

df2 <- bind_cols(df, links)
names(df2)[4] <- "url"

df2 <- df2 |> 
  mutate(url = str_replace_all(url, "http:", "https:"),
         url = str_replace_all(url, " ", "%20"),
         destfile = paste0("C:/Users/PC/Desktop/WB Kosovo/Macro Monitoring/Data/Central Database/Raw Data/CBK/", content, ".xls")) # some links are http:, and we must replace them with https: for safe downloads


df2 |> 
  select(url, destfile) |> 
  pwalk(~download.file(url = .x, destfile = .y, mode = "wb")) # downloading all the files at the same time. To add another argument such as mode we use ~download.file() instead of just download.file

#safely(download.file(df2$url[1], destfile = df2$destfile[1]))

 # download.file(
 #   url = "https://bqk-kos.org/repository/docs/time_series/01%20Financial%20Corporations%20Survey.xls", 
 #   destfile = "C:/Users/PC/Desktop/testfile.xls",
 #   mode = "wb" # add mode = "wb" to pwalk so that the downloads work! (16.11.2023 - comment to self; 21.11.2023 - fixed it; might require a different fix for Mac)
 # )


