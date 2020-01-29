# de blob 2 (DS) Dialogue Editor
A dialogue editor for de blob 2 (DS)

### To Start
Clone or download the repository. [Get RubyInstaller](https://rubyinstaller.org/downloads/), and run it to install Ruby. After installing Ruby you can open the .rb file with the Ruby interpreter (or start the command prompt with Ruby, navigate to the DB2-DS-DE-master folder, and execute `ruby editor.rb`).
The version should not matter too much, but **Ruby+Devkit 2.6.5-1 (x64)** was used during testing.

### To Use
Extract the files from your de blob 2 (DS) .nds file. Inside the **string_tables** folder you will find many .str files containing all of the game's dialogue. This program can edit the dialogue inside of the chapterX_language.str files, change the cameos that show up when displaying dialogue using the chapterX_command.str files, and can use the chapterX_header.str files to help do so.

### Functionality
This application can edit game dialogue in both plaintext and hex (does not work for chapter 7, at least not yet). *This application does not have the ability to edit dialogue to contain more characters, at least not reliably (it would technically be possible using the non-header hex editing function)*. It can also edit the cameos found to the right of dialogue (also using header IDs), although the methods for the use of this function are not documented.

### Errors 
This application does not yet have any kind of release, meaning you are more likely to experience glitches while using it. Please submit an issue if you experience any unexpected results when using this application, however minute, to help with this tool's development.
