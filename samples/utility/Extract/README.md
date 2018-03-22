# **Extract Utility**

The extract utility is a simple application that allows you to extract one or more lines from very large files that you cannot open in Notepad or other text editors. A typical use case of the utility is to diagnose Polybase data load failures on specific lines in a very large text file.

The application parameters are very simple; you need to specify the file name (with or without a path) and the start line. The number of lines to extract can also be specified as the third parameter. If it omitted the value defaults to 10 lines.

## Samples;

extract bigfile.txt 234612
extract c:\users\someuser\documents\loadfile.txt 47592190 25
