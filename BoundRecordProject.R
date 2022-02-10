library(stringr)
library(tidyr)
library(dplyr)
library(ggplot2)

#Load in text
text <- readChar("Index_HALF.txt", file.info("Index_HALF.txt")$size)


# Breaks the text at each congress person's name format LAST, I. FIRST
matches <- str_split(text, "(?=(\\n[A-Z]{3,}, (([A-Z]\\. )?)[A-Z]{3,}))")

# Remove newline characters and carriage return 
clean <- gsub("\\r|\\n","", matches[[1]])

# Partitions matches file into list of lists where each entry is a person and what they have said
# In addition makes breaks in sublist at the beginning of their remarks
regex <- '(?<=[A-Z]{3,25},\\s(([A-Z]\\. )?)[A-Z]{3,25})( |,|-|-)|(?<=\\d{3,4}\\.)|(?<=Remark by, on)|(?<=Remarks by, on)|\\n'
members <- lapply(clean, str_split, regex)

#selects only the members listed with remarks by, on
#i.e. only those who spoke
Speaking = members[grep("Remarks by, on",members)]

# Instantiates a data frame   
Table <- data.frame(matrix(ncol = 2, nrow = 0))
colnames(Table) <- c("Name","Topics")

# Creates a df of format Name | Topics 
for (i in 1:length(Speaking)) {
  startlocation <- min(grep('Remarks by, on',Speaking[[i]][[1]]))
  stoplocation <- min(grep('(Votes of.)|(Vote of.)', Speaking[[i]][[1]]),length(Speaking))
  
  for (j in (startlocation+1):(stoplocation-1)) {
   Table <- rbind(Table, as.vector(c(Speaking[[i]][[1]][1],Speaking[[i]][[1]][j])))
  }
  
}


# Label columns 
colnames(Table) <- c("Name","Topics")

# Removes artifact of the pdf being split into columns 
Table <- Table %>% filter(str_detect(Table$Topics,"ContinuedRemarks|Remarks by, on",negate = TRUE)) 

# Now work on separating pages into their own column 
Topicslist <- lapply(Table$Topics, str_split, "(?=[0-9]{3,})", n = 2)
Topics <- "Topics"
Pages <- "Pages"

for (i in 1:length(Topicslist)) {
  Topics <- rbind(Topics, Topicslist[[i]][[1]][1])
  Pages <- rbind(Pages, Topicslist[[i]][[1]][2])
}


# Label columns 
Table$Topics <- Topics[-1]
Table$Page <- Pages[-1]

# Remove topics without pages
Table <- Table[complete.cases(Table), ]

# Remove amended remarks
NoAmends <- "NoAmends"
for (i in 1:length(Table$Page)) {
  n <- length(str_split(Table$Page[i],",")[[1]]) - length(grep("A|a",str_split(Table$Page[i],",")[[1]]))
  NoAmends <- rbind(NoAmends,n)
}

Table$NoAmends <-  NoAmends[-1]

#Remove middle initial to agree with provided csv. May not be a necessary step
#Depending on how you format your own house and senate csvs
a <- str_split(Table$Name[1:length(Table$Name)]," ")
listOfNames <- c("NoInitals")

for (i in 1:length(a)) {
  listOfNames <- rbind(listOfNames, paste(a[[i]][1],a[[i]][length(a[[i]])], sep=" "))
}


# Label colmn 
Table$Name <- listOfNames[-1]


#Save full data
write.csv(Table,"Bound.csv")

#Separate into House and Senate 
house <- read.csv("members_House_83.csv") %>% mutate(name = toupper(name)) %>% rename(Name = name) 
senate <- read.csv("members_Senate_83.csv") %>% mutate(name = toupper(name))

# Use join to select House and senate 
housetopics <- Table %>% right_join(house, by = "Name") %>%
                group_by(Name) %>% summarise(Pages = sum(as.numeric(NoAmends)), UniqueTopics =  n())


housetopics <- topics %>% filter(topics$Name %in% house$name) %>%
                group_by(Name) %>% summarise(Pages = sum(as.numeric(NoAmends)), UniqueTopics =  n())

senatetopics <- topics %>% filter(topics$Name %in% senate$name) %>% 
                  group_by(Name) %>% summarise(Pages = sum(as.numeric(NoAmends)), UniqueTopics = n())


members <- Table %>% filter(NoAmends != 0) %>%  group_by(Name) %>%  summarise(UniqueTopics = n())
write.csv(members, "members.csv")
write.csv(Table, "topics.csv")

write.csv(housetopics, "housetopics.csv")
write.csv(senatetopics, "senatetopics.csv")

ggplot(housetopics,aes(UniqueTopics)) + geom_histogram(binwidth = 5) + xlab("Unique Topic Count") + labs(title = "Unique Topics for House '53")
ggplot(senatetopics,aes(UniqueTopics)) + geom_histogram(binwidth = 5) + xlab("Unique Topic Count") + labs(title = "Unique Topics for Senate '53")

