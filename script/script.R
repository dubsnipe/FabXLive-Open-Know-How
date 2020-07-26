require(tibble)
require(dplyr)
require(xml2)
require(rvest)
require(yaml)
require(tidyr)
require(tidytext)
require(ggplot2)
require(magrittr)
require(networkD3)

# Scrape a list of urls from the webpage using xml2 and rvest.
scraplinks <- function(url){
  # Create an html document from the url
  webpage <- xml2::read_html(url)
  # Extract the URLs
  url_ <- webpage %>%
    rvest::html_nodes("a") %>%
    rvest::html_attr("href")
  # Extract the link text
  link_ <- webpage %>%
    rvest::html_nodes("a") %>%
    rvest::html_text()
  return(tibble(link = link_, url = url_))
}
links <- scraplinks(URL)

# Sorry for hardcoding the url. Change if you ever use this.
manifests <- paste0("https://emiliovelis.com/okh/manifests/", links$link)

# Check the local path of the script
relative_path <- dirname(rstudioapi::getSourceEditorContext()$path)
new_path <- paste0(relative_path, "/../workshop_manifests/")

# Download all manifests

## Create `new_filenames` as an empty data frame.
new_filenames <- bind_cols(old=links$link, new=as.character(NA), title=as.character(NA))

## Look for the title inside of the manifest. That is `new_title`. 
## Create a ´new_name´ for these files based off the title.
for(i in 1:length(links$link)){
  new_title <- gsub("title: ", "", readLines(manifests[i])[grepl("title: ", readLines(manifests[i]))])
  new_name <- paste0(
    "okh-",
    gsub("\\s+", "_", new_title),
    ".yml"
    )
  new_filenames[i,]$new <- new_name
  new_filenames[i,]$title <- new_title
  download.file(manifests[i], destfile=paste0(new_path, new_name))
}

# Read all the manifests and add into a list.
yaml_list <- list()
for(i in 1:nrow(new_filenames)){
  yaml_list[[i]] <- read_yaml(paste0(new_path, new_filenames$new[i]))
}

# Get titles, descriptions and keywords from the manifests.
## Check that we haven't really used descriptions in this exercise yet, but they could be!
title <- NA
manifest_titles <- tibble(title = lapply(yaml_list, with, title) %>% unlist)
unique_titles <- unique(manifest_titles$title)
manifest_titles <- unique_titles


## Remove from `yaml_list` all repeated elements
if (length(yaml_list) != length(unique_titles)){
  for(i in 1:length(yaml_list)){
    if(yaml_list[[i]]$title %in% unique_titles){
      unique_titles <- unique_titles[-which(unique_titles %in% yaml_list[[i]]$title)]
    } else {
      yaml_list[[i]] <- NULL
    }
  }
}

description <- NA
manifest_descriptions <- tibble(description = lapply(yaml_list, with, description) %>% unlist)
keywords <- NA
## Get a list of keywords. There are multiple keywords per manifest.
manifest_keywords <- sapply(yaml_list, with, keywords)

# Give an id to all titles.
## Notice that they're in group 1. Keywords will be in group 2
## In order to render them in different colors on the graph.
all_titles <- bind_cols(title=manifest_titles,number=seq(1:length(manifest_titles)))
all_titles$group <- 1

title_rows <- nrow(all_titles)

# Get a list of keywords
## Make all keywords lowercase.
unique_keywords <- tolower(unique(unlist(manifest_keywords)))

## Check how many times each keyword is used.
keyword_count <- tibble(keyword=tolower(unlist(manifest_keywords))) %>% 
  group_by(keyword) %>% 
  summarize(n=n())

# Give an number to keywords that continues the list of titles.
## Add keywords into group 2.
all_keywords <- bind_cols(
  title=unique_keywords,
  number=seq(from=title_rows+1, to=title_rows+length(unique_keywords))
  )
all_keywords$group <- 2


# Make a general list of all nodes (device titles and keywords).
all_nodes <- bind_rows(all_titles, all_keywords)
all_nodes <- all_nodes %>% mutate(number=number-1) %>% drop_na()


## Testing alternative way
manifest_single_keywords <- tibble(title=character(), keyword=character())
for (i in 1:length(manifest_titles)) { 
  manifest_single_keywords <- bind_rows(manifest_single_keywords, 
                                        bind_cols(title=manifest_titles[i],
                                                  keyword=yaml_list[[i]]$keywords))
}
manifest_single_keywords <- drop_na(manifest_single_keywords)
manifest_single_keywords$keyword <- tolower(manifest_single_keywords$keyword)


## Join a list of item ids (keywords and titles) and keyword use count.
manifest_links <- left_join(manifest_single_keywords, all_nodes) %>% 
  mutate(item1=number, name=title) %>% 
  select(-number, -title)
manifest_links <- 
  left_join(manifest_links %>% select(-group), all_nodes, by=c("keyword"="title")) %>% 
  mutate(item2=number) %>% 
  select(-number)
## We're multiplying `n` just to make it easier to see.
manifest_links <- left_join(manifest_links, keyword_count) %>% 
  mutate(n=n+2*2)


# Read the evaluations which are stored from the website on a csv file.
## `weights` is simply a vector with weighted values for each question.
evals <- read.csv(url("https://emiliovelis.com/okh/eval.csv"), header=T)
weights <- c(.3, .2, .25, .1, .15)
values <- left_join(evals, new_filenames) %>% select(-old) %>% 
  mutate(value=q1*weights[1]+q2*weights[2]+q3*weights[3]+q4*weights[4]+q5*weights[5]) %>% 
  select(title, value) %>% 
  drop_na() %>% 
  group_by(title) %>% 
  summarize(value=mean(value))

# Pair every node with its score.

## Keywords don't have a value here (it's shown as line weight)
## So we'll give them a default value of 5.
all_values <- left_join(all_nodes, values)
all_values$value[is.na(all_values$value)] <- 5
## Add exponentiality just for sake of visualizing better.
all_values <- all_values %>% 
  mutate(x_value=case_when(group==2 ~5, TRUE ~ (value^1.4)))


## Make sure to eliminate projects without keywords.
`%notin%` <- Negate(`%in%`)
all_values %>% filter(keywords %notin% manifest_links$keyword)

# Draw the diagram!

## Adding a color scale.
ColourScale <- 'd3.scaleOrdinal()
            .domain(["lions", "tigers"])
           .range(["#0072ff", "#694489"]);'

## Graph is possible thanks to the beautiful NetworkD3 package.
## https://christophergandrud.github.io/networkD3/
network <- forceNetwork(
  Links=manifest_links %>% select(item1, item2, n), 
  Nodes=all_values %>% select(title,group,x_value), 
  Source="item1", 
  Target="item2", 
  Value="n", 
  NodeID="title", 
  Nodesize="x_value", 
  radiusCalculation="d.nodesize", 
  Group="group",
  opacity=1, 
  zoom = T,
  fontFamily = "League Mono",
  colourScale = JS(ColourScale),
  linkDistance = 
    JS('function(){d3.select("body").style("background-color", "#9fd2f9"); return 50;}')
  )
network

## Save graph as a webpage.
network %>% saveNetwork(file = paste0(new_path, "../script/graph-output.html"))
