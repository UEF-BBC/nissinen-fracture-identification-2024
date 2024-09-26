# import required libraries
library(RSQLite)
library(dplyr)
library(readr)
library(stringr)

# connect to an SQLite database
conn <- dbConnect(RSQLite::SQLite(), "register_and_pacs_data.db")


### HUMERUS FRACTURE IDENTIFICATION ###

humerus_pacs_data <- dbGetQuery(conn, read_file("query_humerus_pacs.sql"))
cat("Humerus examination series in PACS: ", nrow(humerus_pacs_data))

humerus_pacs_2plus <- filter(humerus_pacs_data, pacs_exam_count >= 2 & request_type != 'elective' & exam_date != pacs_max_date)
cat("Humerus PACS2+ identified fractures: ", nrow(humerus_pacs_2plus))

humerus_pacs_3plus <- filter(humerus_pacs_data, pacs_exam_count >= 3 & request_type != 'elective' & exam_date != pacs_max_date)
cat("Humerus PACS3+ identified fractures: ", nrow(humerus_pacs_3plus))

# query register data (with diagnosis code S42.2)
query_registers <- read_file("query_humerus_register.sql")
humerus_register_data <- dbGetQuery(conn, query_registers)
cat("Humerus register identified fractures: ", nrow(humerus_register_data))

humerus_combined_a <- filter(humerus_register_data, pacs_exam_count >= 1)
cat("Humerus combined A identified fractures: ", nrow(humerus_combined_a))

# query register data with extended diagnosis codes (S42.2, S42, S423, L76) 
query_registers_extended <- str_replace_all(query_registers, "'S422'", "'S422', 'S42', 'S423', 'L76'")
humerus_register_data_extended <- dbGetQuery(conn, query_registers_extended)

humerus_combined_b <- filter(humerus_register_data_extended, pacs_exam_count >= 2 | (pacs_exam_count == 1 & diagnosis_code == 'S422'))
cat("Humerus combined B identified fractures: ", nrow(humerus_combined_b))



### WRIST FRACTURE IDENTIFICATION ###

wrist_pacs_data <- dbGetQuery(conn, read_file("query_wrist_pacs.sql"))
cat("Wrist examination series in PACS: ", nrow(wrist_pacs_data))

wrist_pacs_2plus <- filter(wrist_pacs_data, pacs_exam_count >= 2)
cat("Wrist PACS2+ identified fractures: ", nrow(wrist_pacs_2plus))

wrist_pacs_3plus <- filter(wrist_pacs_data, pacs_exam_count >= 3)
cat("Wrist PACS3+ identified fractures: ", nrow(wrist_pacs_3plus))

wrist_register_data <- dbGetQuery(conn, read_file("query_wrist_register.sql"))
cat("Wrist register identified fractures: ", nrow(wrist_register_data))

wrist_combined_a <- filter(wrist_pacs_data, pacs_exam_count >= 3 | (pacs_exam_count == 2 & register_contact_count > 0))
cat("Wrist combined A identified fractures: ", nrow(wrist_combined_a))

# combine data from register and pacs queries
wrist_combined_b_reg_part <- filter(wrist_register_data, pacs_exam_count == 0 & register_contact_count >= 3)
wrist_combined_b_reg_part <- wrist_combined_b_reg_part[c('patient_id','index_date')]
wrist_combined_a_part <- wrist_combined_a[c('patient_id','index_date')]
wrist_combined_b <- bind_rows(wrist_combined_b_reg_part, wrist_combined_a_part)
cat("Wrist combined B identified fractures: ", nrow(wrist_combined_b))

# close database connection
dbDisconnect(conn)
