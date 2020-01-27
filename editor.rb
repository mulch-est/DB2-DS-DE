def padEnd(input)
  ""+input+" "
end

def padTo(num, input)
  if input.length > num
    while input.length > num
      input.chop
    end
    return input
  elsif input.length < num
    while input.length < num
      input = input + " "
    end
    return input
  else
    return input
  end
end

def replaceAscii(replace_filepath, replaced_ascii, new_ascii)
  asciireplace_filedata = File.read(replace_filepath)
  asciireplace_newfiledata = asciireplace_filedata.gsub(replaced_ascii.to_s, new_ascii.to_s)
  puts "Successfully replaced ascii data..."
  File.write(replace_filepath, asciireplace_newfiledata)
  puts "Successfully wrote new data to file..."
  puts "--ASCII view--"
  puts "#{asciireplace_newfiledata}"
end

def ascii_header_menu(filepath, header_filepath, headers, replace_header)
  if headers.include? replace_header
    replace_index = -1
    headers.each { |i|
      replace_index = replace_index + 1
      if i == replace_header
        break
      end
    }
    #puts "Replacing dialogue ##{replace_index}"
    #go through dialogue, match one to header, and get character limit from it's "spacer tag"
    log_data = File.binread(filepath) #doesn't stop at 1A on Windows if using binread
    logs = []
    log_heads = []
    charlims = []
    last_i = ""
    last_ii = ""
    last_it = ""
    curr_log = ""
    curr_loghead = ""
    collecting_log = 0
    collecting_loghead = 5

    # do last i, last last i to make sure you are getting 00 XX(!00) 00 XX(!00) 00
    #copy-paste begins
    log_data.split("").each do |i| #iterates over each character in log_data
      if i.unpack('H*')[0] == "00" && collecting_log > 0
        curr_log.slice!(0, 1) #easily removes the u/0000 that starts each dialogue otherwise
        logs.push(curr_log)
        curr_log=""
        collecting_log = 0
      end
      if i.unpack('H*')[0] == "00"
        if last_i == "00"
          curr_loghead = ""
        elsif curr_loghead == "" && collecting_log == 0
          collecting_loghead = 5
        end
      end
      if last_i == "00" && i.unpack('H*')[0] != "00" && curr_loghead.length == 2
        charlims.push((i.unpack('H*')[0]).to_i(16))
      end
      if last_i != "00" && i.unpack('H*')[0] == "00" && curr_loghead.length == 8
        collecting_log=5
        collecting_loghead=0
        curr_log=""
        curr_loghead=""
      end
      last_it = last_ii
      last_ii = last_i
      if collecting_loghead > 0
        last_i = i.unpack('H*')[0]
        curr_loghead = curr_loghead + i.unpack('H*')[0]
      elsif collecting_log > 0
        last_i = i
        curr_log = curr_log + i
      end
      #puts "i:#{i}, curr_loghead:#{curr_loghead}, curr_log:#{curr_log}, col_l:#{collecting_log}, col_lh:#{collecting_loghead}"
    end
    #puts "log_heads: #{log_heads}" #blank?
    #puts "charlims: #{charlims}"
    #puts "logs: #{logs}"
    #copy-paste ends
    puts "Please enter the ASCII code you would like to replace in #{replace_header}"
    puts "Limit is #{charlims[replace_index]} chars, enter less: excess is padded with spaces, enter more: excess is deleted"
    new_ascii = gets.chop

    puts "Replacing dialogue in #{replace_header} in #{File.basename(filepath)} with #{new_ascii} (#{new_ascii.length} chars), is this ok?  Y/N"
    ascii_replace_confirmation = gets.chop

    if ascii_replace_confirmation == "y" || ascii_replace_confirmation == "Y"
      #puts replace_index
      replaceAscii(filepath, logs[replace_index], padTo(charlims[replace_index], new_ascii))
      puts "Replaced #{logs[replace_index]} with #{padTo(charlims[replace_index], new_ascii)}"
      menu(filepath)
    else
      puts "Replacement was not confirmed."
      menu(filepath)
    end
  else
    "Invalid header. Please try again."
    ascii_header_menu(filepath, header_filepath, headers, gets.chop)
  end
end

def ascii_header_replace_menu(filepath, header_filepath)
  if File.exists?(header_filepath)
    header_filechars = File.size(header_filepath)
    puts "Opened #{File.basename(header_filepath)} [#{header_filechars} bytes]"

    header_data = File.binread(header_filepath) #doesn't stop at 1A on Windows if using binread
    headers = []
    # do last i, last last i to make sure you are getting 0X_0X_X*X_0X
    last_i = ""
    last_ii = ""
    last_it = ""
    curr_head = ""
    collecting_header = 0
    #puts header_data
    header_data.split("").each do |i| #iterates over each character in header_data
      if i == "0"
        if curr_head == ""
          collecting_header = 5
        elsif last_i == "_" && last_it != "0"
          collecting_header = 2
        end
      end
      if last_ii == "0" && i != "_" && curr_head.length == 2
        collecting_header=0
        curr_head=""
      end
      last_it = last_ii
      last_ii = last_i
      last_i = i
      if collecting_header > 0
        curr_head = curr_head + i
        if collecting_header == 1 || collecting_header == 2
          if !headers.include? curr_head
            collecting_header = collecting_header - 1
            if collecting_header == 0
              headers.push(curr_head)
              curr_head=""
            end
          end
        end
      end
      #puts "i:#{i}, curr_head:#{curr_head}"
    end
    puts "headers: #{headers}"
    puts "Please enter the header of the dialogue you would like to change (ie 01_01_BLOT_01)"
    replace_header = gets.chop
    ascii_header_menu(filepath, header_filepath, headers, replace_header)
  else
    puts "Could not read the file."
    ascii_header_replace_menu(filepath, gets.chop)
  end
end

def start()
  puts "Please enter the filepath of the dialogue (ie chapterX_language.str)" #change to name of the dialogue file when data/ forced

  filepath = gets.chop #add data/ eventually

  if File.exists?(filepath)
    filechars = File.size(filepath)
    puts "Opened #{File.basename(filepath)} [#{filechars} bytes]"
    #Menu navigation begins here, replace with a function for multiple edits rather than restarting the program eventually
    menu(filepath)
  else
    puts "Your file at (#{filepath}) could not be located. Please try again"
    start()
  end
end

def menu(filepath)
  puts "Press 1 for automatic ASCII editing"
  puts "Press 2 for automatic hex editing"
  puts "Press 3 to view ASCII file data"
  puts "Press 4 to view hex file data"
  puts "Press 5 to change the dialogue file"
  puts "Press 6 to change dialogue cameo"
  puts "Press any other button to quit"

  file_edit_option = gets.chop

  if file_edit_option == "1"
    puts "Would you like to use the chapter header to replace ASCII Y/N"
    puts "(Using the header is less likely to glitch the game, although it will not work for chapter 7)"
    ascii_file_edit_option = gets.chop

    if ascii_file_edit_option == "y" || ascii_file_edit_option == "Y"
      puts "Please enter the filepath of the header (ie chapterX_header.str)"
      header_filepath = gets.chop

      ascii_header_replace_menu(filepath, header_filepath)
    else #non-header auto ascii replace
      puts "Please enter the ASCII code you would like to change"
      replaced_ascii = gets.chop

      puts "Please enter the ASCII code you would like to replace #{replaced_ascii} with"
      new_ascii = gets.chop

      puts "Replacing all #{replaced_ascii} in #{File.basename(filepath)} with #{new_ascii}, is this ok? Y/N"
      ascii_replace_confirmation = gets.chop

      if ascii_replace_confirmation == "y" || ascii_replace_confirmation == "Y"
        replaceAscii(filepath, replaced_ascii, new_ascii)
      else
        puts "Replacement was not confirmed."
        menu(filepath)
      end
    end
  elsif file_edit_option == "2"
    puts "Please enter the hex code you would like to change"
    replaced_hex = gets.chop

    puts "Please enter the hex code you would like to replace #{replaced_hex} with"
    new_hex = gets.chop

    puts "Replacing all #{replaced_hex} in #{File.basename(filepath)} with #{new_hex}, is this ok? Y/N"
    hex_replace_confirmation = gets.chop

    if hex_replace_confirmation == "y" || hex_replace_confirmation == "Y"
      hexreplace_filedata = File.read(filepath)
      hexreplace_newfiledata = hexreplace_filedata.gsub([replaced_hex].pack('H*'), [new_hex].pack('H*'))
      puts "Successfully replaced hex data..."
      File.write(filepath, hexreplace_newfiledata)
      puts "Successfully wrote new data to file..."
      puts "--ASCII view--"
      puts "#{hexreplace_newfiledata}"
    else
      puts "Replacement was not confirmed."
      menu(filepath)
    end
  elsif file_edit_option == "3"
    #viewAscii()
    puts "--ASCII view--"
    #file_data = File.foreach(filepath) { |line| puts line }
    file_data = File.binread(filepath)
    puts file_data
    puts "--ASCII view--"
    menu(filepath)
  elsif file_edit_option == "4"
    #viewHex()
    puts "--HEX view--"
    file_readable_hexdata = [];
    hexline=""
    number = 0 #used for counting where the next hex pair should be placed
    file_hexdata = File.binread(filepath)
    file_hexdata.unpack('H*')[0].scan(/../).each {|item|
      hexline = hexline + padEnd(item)
      number = number + 1
      #after the 16th hexpair, start next line
      if number == 16
        file_readable_hexdata.push(hexline)
        hexline=""
        number = 0
      end
    }
    file_readable_hexdata.push(hexline) #writes last line if last line has <16 hex pairs

    file_readable_hexdata.each { |item|
      puts item
    }

    puts "--HEX view--"
    menu(filepath)
  elsif file_edit_option == "5"
    start()
  elsif file_edit_option == "6"
    puts "Please enter the filepath of the command file (ie chapter1_command.str)"
    command_filepath = gets.chop

    if File.exists?(command_filepath)
      #puts "Would you like to use the chapter header to replace ASCII Y/N"
      #puts "(Using the header will not work for chapter 7)"
      #ascii_file_edit_option = gets.chop

      #find correct "spacer tag" and replace second value in the command file

puts "Enter header path to do the swappage yah?"
      header_filepath = gets.chop
      #create def to save on file inputs?

#copy-paste begins
      if File.exists?(header_filepath)
      header_filechars = File.size(header_filepath)
      puts "Opened #{File.basename(header_filepath)} [#{header_filechars} bytes]"

    header_data = File.binread(header_filepath) #doesn't stop at 1A on Windows if using binread
    headers = []
    # do last i, last last i to make sure you are getting 0X_0X_X*X_0X
    last_i = ""
    last_ii = ""
    last_it = ""
    curr_head = ""
    collecting_header = 0
    #puts header_data
    header_data.split("").each do |i| #iterates over each character in header_data
      if i == "0"
        if curr_head == ""
          collecting_header = 5
        elsif last_i == "_" && last_it != "0"
          collecting_header = 2
        end
      end
      if last_ii == "0" && i != "_" && curr_head.length == 2
        collecting_header=0
        curr_head=""
      end
      last_it = last_ii
      last_ii = last_i
      last_i = i
      if collecting_header > 0
        curr_head = curr_head + i
        if collecting_header == 1 || collecting_header == 2
          if !headers.include? curr_head
            collecting_header = collecting_header - 1
            if collecting_header == 0
              headers.push(curr_head)
              curr_head=""
            end
          end
        end
      end
      #puts "i:#{i}, curr_head:#{curr_head}"
    end
    #puts "headers: #{headers}"
    #puts "Please enter the header of the dialogue you would like to change (ie 01_01_BLOT_01)"
    #replace_header = gets.chop
    #ascii_header_menu(filepath, header_filepath, headers, replace_header)
  else
    #puts "Could not read the file."
    #ascii_header_replace_menu(filepath, gets.chop)
  end

      #NOW, get headers and use them as index referencer, similar to auto-ascii replace

      #menu(filepath)
    #else 
      #put "Could not read the file at (#{command_filepath})"
      #menu(filepath) #<<<change later
    #end
    puts "headers: #{headers}"
puts "Pick the header, ok?"
picked_header = gets.chop
#^ save for wrong header inputs

puts "Pick the cameo, yahear?"
picked_cameo = gets.chop

replace_index = -1
    headers.each { |i|
      replace_index = replace_index + 1
      if i == picked_header
        break
      end
    }
puts "got replace_index of #{replace_index}"

      command_data = File.binread(command_filepath) #doesn't stop at 1A on Windows if using binread

      spacers = []
      last_i = ""
      last_ii = ""
      last_it = ""
      curr_spacer = ""
      collect = 1
      num = 0
      command_new_data = "";
      #begin copy-paste
      # do last i, last last i to make sure you are getting 00 XX(!00) 00 XX(!00) 00
      #copy-paste begins
      command_data.split("").each do |i| #iterates over each character in log_data
        command_new_data = command_new_data + i;
        if i.unpack('H*')[0] == "00"
          if last_i == "00"
            curr_spacer = ""
          end
        end
        if i.unpack('H*')[0] != "00"
          if last_i != "00"
            curr_spacer = ""
            collect = 0
          end
        end
        if last_it != "00" && last_ii == "00" && last_i != "00" && i.unpack('H*')[0] == "00" && curr_spacer.length == 8
          if spacers.length == replace_index
#writes over file while reading
puts "cs: #{curr_spacer}, ncs: #{curr_spacer[0, 6] + picked_cameo}, ri: #{replace_index}, ph: #{picked_header}"
puts "old: #{command_new_data}, new: #{command_new_data[0, num-4] + (curr_spacer[0, 6] + picked_cameo)}"
            command_new_data = command_new_data[0, num-4] + [curr_spacer[0, 6] + picked_cameo + "00"].pack('H*')

#spacers[replace_index][0, 6] + picked_cameo
          end
            spacers.push(curr_spacer)
          
          curr_spacer=""
        end
        last_it = last_ii
        last_ii = last_i
        last_i = i.unpack('H*')[0]
        if collect == 1
          curr_spacer = curr_spacer + i.unpack('H*')[0]
        end
        collect = 1
        num = num + 1

        #puts "i:#{i}, cs:#{curr_spacer}"
      end
      puts "s: #{spacers}"
      #^returns 00XX00YY
      #end copy-paste

      
puts command_new_data.unpack('H*')[0]
#replace hex of spacers[headernum] to 00XX00ZZ(00)

      File.write(command_filepath, command_new_data)


#^that should be func
  puts "Ding!"
  menu(filepath)
end
  else
   puts "my bad"
    #answer = gets.chop
    #if answer == "y" || answer == "Y"
     # puts "Exited the program."
    ##  menu(filepath)
    
  end
  #^end copy-paste
end

start()
