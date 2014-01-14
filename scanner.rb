# scanner.rb
# John Musgrave
# Abstract:  This is the scanner to handle our lexical analysis

# in x = x + y

# this is our hash of symbols
tokens = {}

# define tokens
tokens[:assign] = "="
tokens[:semi_colon] = ";"
tokens[:l_paren] = "("
tokens[:r_paren] = ")"

# get filename from command line argument
file_in = ARGV[0]

if file_in.nil?
	# file not found
	puts "Fatal:  File not found.  Please enter a valid filename."
else
	# open the file
	File.open(file_in, 'r') do |f|
	  # get characters from the file
	  while c = f.getc	  	
	    # if tokens.has_value? c
	    	# current_token += c
	    # else
	    	# while c != ' '
	    		# current_token += c
	    		# c = f.getc
	    	# end	    	
	    # end
	  end
	end
end
  
# create new file
# File.open('test.rb', 'w') do |f|
	# write
  
#end
