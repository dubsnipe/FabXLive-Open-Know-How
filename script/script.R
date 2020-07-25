# require(tidyverse)
require(tibble)
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
manifests <- paste0("https://emiliovelis.com/okh/manifests/", links$link)


relative_path <- dirname(rstudioapi::getSourceEditorContext()$path)
new_path <- paste0(relative_path, "/../workshop_manifests/")

# Download all manifests
new_filenames <- bind_cols(old=links$link, new=as.character(NA), title=as.character(NA))
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

yaml_list <- list()
for(i in 1:nrow(new_filenames)){
  yaml_list[[i]] <- read_yaml(paste0(new_path, new_filenames$new[i]))
}

# Drawing a list
title <- NA
manifest_titles <- tibble(title = lapply(yaml_list, with, title) %>% unlist)
description <- NA
manifest_descriptions <- tibble(description = lapply(yaml_list, with, description) %>% unlist)

keywords <- NA
manifest_keywords <- sapply(yaml_list, with, keywords)

all_titles <- bind_cols(title=manifest_titles,number=seq(1:nrow(manifest_titles)))
all_titles$group <- 1
title_rows <- nrow(all_titles)
unique_keywords <- tolower(unique(unlist(manifest_keywords)))
keyword_count <- tibble(keyword=tolower(unlist(manifest_keywords))) %>% group_by(keyword) %>% summarize(n=n())
all_keywords <- bind_cols(title=unique_keywords,number=seq(from=title_rows+1, to=title_rows+length(unique_keywords)))
all_keywords$group <- 2
all_nodes <- bind_rows(all_titles, all_keywords)
all_nodes <- all_nodes %>% mutate(number=number-1)

manifest_single_keywords <- tibble(title=character(), keyword=character())
for (i in 1:nrow(manifest_titles)) { 
  x <- tibble(title=as.character(manifest_titles[i,]), keyword=manifest_keywords[[i]]) %>% unnest(keyword)
  manifest_single_keywords <- bind_rows(manifest_single_keywords, x)
}
manifest_single_keywords <- drop_na(manifest_single_keywords)
manifest_single_keywords$keyword <- tolower(manifest_single_keywords$keyword)

manifest_links <- left_join(manifest_single_keywords, all_nodes) %>% 
  mutate(item1=number, name=title) %>% 
  select(-number, -title)

manifest_links <- 
  left_join(manifest_links %>% select(-group), all_nodes, by=c("keyword"="title")) %>% 
  mutate(item2=number) %>% 
  select(-number)

manifest_links <- left_join(manifest_links, keyword_count) %>% 
  mutate(n=n*2) # For visual correction


# Reading evaluation
evals <- read.csv(url("https://emiliovelis.com/okh/eval.csv"), header=T)
weights <- c(.3, .2, .25, .1, .15)
values <- left_join(evals, new_filenames) %>% select(-old) %>% 
  mutate(value=q1*weights[1]+q2*weights[2]+q3*weights[3]+q4*weights[4]+q5*weights[5]) %>% 
  select(title, value)

all_values <- left_join(all_nodes, values)
all_values$value[is.na(all_values$value)] <- 5

forceNetwork(Links=manifest_links %>% select(item1, item2, n), 
             Nodes=all_values %>% select(title,group,value), 
             Source="item1", 
             Target="item2", 
             Value="n", 
             NodeID="title", 
             Nodesize="value", 
             radiusCalculation="d.nodesize", 
             opacity=1, 
             Group="group",
             )

