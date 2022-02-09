# IndexReader
Python and R script that will read bound congressional record and process it into a workable csv. 
Provied is a smaple csv of the first three hundred pages from the 83rd congress.

The Python files process the Bound record into a txt file, then the r script pasrese the text file into a csv. The final form should be a csv with columns Name, Topic, Page (of the index), NoAmends (number of pages minus amendments). 


Future improvements would include making the regex commands more robust so they can handle incorrect ocr readings. There may be an upper limit to the amount of progress that can be made on that front as the scan quality of the bound record is low. It may be the case that perfectly read in the document the scans will have to be redone at a higher resolution. 
