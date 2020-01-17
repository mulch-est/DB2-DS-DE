def padEnd(input)
  ""+input+" "
end

puts "Please enter the filepath of the dialogue (ie chapterX_language.str)" #change to name of the dialogue file when data/ forced

filepath = gets.chop #add data/ eventually
filechars = File.size(filepath)

if File.exists?(filepath)
  puts "Opened #{File.basename(filepath)} [#{filechars} bytes]"

  puts "--ASCII view--"
  file_data = File.foreach(filepath) { |line| puts line }

  puts "--HEX view--"

  file_readable_hexdata = [];
  hexline=""
  number = 0 #used for counting where the next hex pair should be placed

  file_hexdata = File.open(filepath).readlines
  file_hexdata.each {|readline|
    readline.unpack('H*')[0].scan(/../).each {|item|
      hexline = hexline + padEnd(item)
      number = number + 1
      #after the 16th hexpair, start next line
      if number == 16
        file_readable_hexdata.push(hexline)
        hexline=""
        number = 0
      end
    }
  }
  file_readable_hexdata.push(hexline) #writes last line if last line has <16 hex pairs

  file_readable_hexdata.each { |item|
    puts item
  }

  #Menu navigation begins here, replace with a function for multiple edits rather than restarting the program eventually
  
  puts "Press 1 for automatic ASCII editing"
  puts "Press 2 for automatic hex editing"
  puts "Press any other button to quit"

  file_edit_option = gets.chop

  if file_edit_option == "1"
    puts "Would you like to use the chapter header to replace ASCII Y/N"
    puts "(If you do not, a glitchless game cannot be guaranteed)"
    ascii_file_edit_option = gets.chop
    
    if ascii_file_edit_option == "y"
      puts "Please enter the filepath of the header (ie chapterX_header.str)"
      
      header_filepath = gets.chop
      header_filechars = File.size(header_filepath)
      
      if File.exists?(header_filepath)
        puts "Opened #{File.basename(header_filepath)} [#{header_filechars} bytes]"
        #print usable headers?
        header_data = File.binread(header_filepath) #doesn't stop at 1A on Windows if using binread
        headers = []
        # do last i, last last i to make sure you are getting 0X_0X_X*X_0X
        last_i = ""
        last_ii = ""
        last_it = ""
        curr_head = ""
        collecting_header = 0
        puts header_data
        header_data.split("").each do |i| #iterates over each character in header_data
          if i == "0"
            if curr_head == ""
              collecting_header = 5
            elsif last_i == "_" && last_it != "0"
              collecting_header = 2
            end
          end
          last_it = last_ii
          last_ii = last_i
          last_i = i
          if collecting_header > 0
            curr_head = curr_head + i
            if collecting_header == 1 || collecting_header == 2
              collecting_header = collecting_header - 1
              if collecting_header == 0
                headers.push(curr_head)
                curr_head=""
              end
            end
          end
          puts "i:#{i}, curr_head:#{curr_head}"
        end
        puts "headers: #{headers}"
        puts "Please enter the header of the dialogue you would like to change (ie 01_01_BLOT_01)"
        replace_header = gets.chop

        puts "Please enter the ASCII code you would like to replace in #{replace_header}"
        new_ascii = gets.chop
        
        puts "Replacing dialogue in #{replace_header} in #{File.basename(filepath)} with #{new_ascii}, is this ok? Y/N"
        ascii_replace_confirmation = gets.chop
        
        if ascii_replace_confirmation == "y"
          #do ascii replace using header
        else 
          puts "Exited the program."
        end
      else
        puts "Could not read the file. Exited the program"
      end
    else
      puts "Please enter the ASCII code you would like to change"
      replaced_ascii = gets.chop

      puts "Please enter the ASCII code you would like to replace #{replaced_ascii} with"
      new_ascii = gets.chop

      puts "Replacing all #{replaced_ascii} in #{File.basename(filepath)} with #{new_ascii}, is this ok? Y/N"
      ascii_replace_confirmation = gets.chop

      if ascii_replace_confirmation == "y"
        asciireplace_filedata = File.read(filepath)
        asciireplace_newfiledata = asciireplace_filedata.gsub(replaced_ascii, new_ascii)
        puts "Successfully replaced ascii data..."
        File.write(filepath, asciireplace_newfiledata)
        puts "Successfully wrote new data to file..."
        puts "--ASCII view--"
        puts "#{asciireplace_newfiledata}"
      else
        puts "Exited the program"
      end
    end
  elsif file_edit_option == "2"
    puts "Please enter the hex code you would like to change"
    replaced_hex = gets.chop

    puts "Please enter the hex code you would like to replace #{replaced_hex} with"
    new_hex = gets.chop

    puts "Replacing all #{replaced_hex} in #{File.basename(filepath)} with #{new_hex}, is this ok? Y/N"
    hex_replace_confirmation = gets.chop

    if hex_replace_confirmation == "y"
      hexreplace_filedata = File.read(filepath)
      hexreplace_newfiledata = hexreplace_filedata.gsub([replaced_hex].pack('H*'), [new_hex].pack('H*'))
      puts "Successfully replaced hex data..."
      File.write(filepath, hexreplace_newfiledata)
      puts "Successfully wrote new data to file..."
      puts "--ASCII view--"
      puts "#{hexreplace_newfiledata}"
    else
      puts "Exited the program"
    end
  else
    puts "Exited the program."
  end
else
  puts "Your file could not be located. Exited the program."
end
