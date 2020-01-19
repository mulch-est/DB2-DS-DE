# de blob 2 (DS) Dialogue Editor
A dialogue editor for de blob 2 (DS)

### To Start
Clone or download the repository. [Get RubyInstaller](https://rubyinstaller.org/downloads/), and run it to install Ruby. After installing Ruby you can open the .rb file with the Ruby interpreter (or start the command prompt with Ruby, navigate to the DB2-DS-DE-master folder, and execute `ruby editor.rb`).
The version should not matter too much, but **Ruby+Devkit 2.6.5-1 (x64)** was used during testing.

### To Use
Extract the files from your de blob 2 (DS) .nds file via a program such as dslazy or nitroexplorer, the dialogue is inside the **string_tables** folder. This program can edit the dialogue inside of the chapterX_language.str files, and can use the chapterX_header.str files to help.

### Functionality
This application has very rudimentary systems for automatic editing of both ASCII and hex code, as well as the limited ability to edit ASCII code from a header ID rather than the original document ASCII (does not work for chapter 7, at least not yet).
