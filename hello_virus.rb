#Key=

=begin

Assignment compiled on Ruby (requires the OpenSSL, Digest (MD5), and Base64 libraries to function)

How the program works:

* On first run...
	- the program goes through all of the code, executing each and everything
	- on closing, the program runs an encryptor function
	- the encryptor code takes in a key of random alphanumeric string (between 1 and 65536) and generates an MD5 hash
	- the hash, as MD5 produces a 32 character long string, is perfect and used in an AES CTR (Counter) encryption algorithm
	- the AES encrypted byte string is now passed through a Base64 algorithm to be encrypted into a readable format
	- all of the driver code that needs to be encrypted is now replaced with the encrypted code, and the key saved within itself
* On subsequent run...
	- the program retrieves the stored key and uses it to decrypt the driver code
	- the base64 string is decoded into an AES byte string, which is decoded by using the MD5 hash generated from the retrieved key, and the line of code retrieved
	- the deciphered line of code is now written and called through metaprogramming (as you are unable to alter any executing file under Windows standard)
	- after execution the encryption process takes place (see "On first run...")

=end

require 'openssl' # Library required for AES encryption
require 'digest' # Used explicitly for MD5 hash algorithm (key generation)
require 'base64' # Convert encryption to readable Base64 format ('readable' is subjective here)

#Sequence (for initial execution)
$f_data = nil # This is where we'll store our file's data
$payload = '' # Our code that needs to be deciphered (made it generic for multiple lines of code (does not work as intended however, so left it with "Hello World!" only))
# Let's store the data into a variable
file = File.open(File.basename(__FILE__))
$f_data = file.readlines.map(&:chomp)
file.close

#Functions
def decryptor(key)
	cipher = OpenSSL::Cipher::AES.new(256, :CTR)
	# Using the key and iv, decrypt it
	cipher.decrypt
	hash = Digest::MD5.hexdigest(key)
	cipher.key = hash
	# After receiving the text, overwrite the payload
	rewrite = false
	new_data = []
	for i in (0..$f_data.length()-1) do
		if $f_data[i] == "#Start"
			new_data.push($f_data[i])
			rewrite = true
		elsif $f_data[i] == "#End"
			rewrite = false
			ciphertext = Base64.strict_decode64($payload) # 1 to -1 because the first character will be for commenting the ciphertext
			plaintext = cipher.update(ciphertext) + cipher.final
			new_data.push(plaintext)
			new_data.push($f_data[i])
			$payload = ''
		elsif rewrite == true and $f_data[i] != ""
			$payload += $f_data[i][1..-1]
		else
			new_data.push($f_data[i])
		end
	end
	$f_data = new_data
end

#Start
# It's a seecret!
#End

def encryptor(key)
	new_data = [] # This is where we store contents of file for now
	$payload = ''
	cipher = OpenSSL::Cipher::AES.new(256, :CTR)
	cipher.encrypt
	hash = Digest::MD5.hexdigest(key)
	cipher.key = hash # The hash is used as a key to encrypt the lines
	rewrite = false
	for i in (0..$f_data.length()-1) do
		if $f_data[i][0..4] == "#Key=" # Store Key
			$f_data[i] = "#Key=" + key
			new_data.push($f_data[i])
		elsif $f_data[i] == "#Start" # Check where payload begins
			rewrite = true
			new_data.push($f_data[i])
		elsif $f_data[i] == "#End" # Check where payload ends
			rewrite = false
			ciphertext = cipher.update($payload) + cipher.final
			text = Base64.strict_encode64(ciphertext)
			new_data.push("#" + text)
			new_data.push($f_data[i])
			$payload = ''
		elsif rewrite == true and $f_data[i] != "" # Update deciphered payload with ciphered text
			if not ($f_data[i].is_a? String) # Failsafe as the data itself is treated like an array at times
				$f_data[i] *= ""
			end
			$payload += $f_data[i] + "\n"
		else
			new_data.push($f_data[i])
		end
	end
	$f_data = new_data
end

def generate_key(len=32) # A (pretty useless) code self-written that produces an arbitrary key of specified length (or if unspecified, of length 32)
	$i = 0
	key = ''
	while $i < len do
		$r = rand(48..122)
		if ($r >= 48 and $r <= 57) or ($r >= 65 and $r <= 90) or ($r >= 97 and $r <= 122) # accept only alphanumeric keys (case-insensitive)
			key += $r.chr
			$i += 1
		end
	end
	return key
end

# Now let's retrieve the key (if any)
key = $f_data[0][5..-1]
if key.length != 0 # If true, a key is present so we have to decrypt the payload first
	# Retrieve the MD5 hash for the key
	# Launch the decryptor method to decrypt the payload before running it
	decryptor(key)
	evaluation = false
	for i in (0..$f_data.length()-1)
		if $f_data[i] == "#Start"
			evaluation = true
		elsif $f_data[i] == "#End"
			evaluation = false
		elsif evaluation
			code = $f_data[i].split("\n")
			for j in code
				eval(j)
			end
		end
	end
end # If false, the code is executing for the first time (or if a key is not provided, it will work as intended, since all of the encrypted code is commented, so the program will ignore it)

key = generate_key(rand(1..65536)) # This is going to emotionally hurt someone
 # This will work whether it's first time or subsequent execution - a new key will be generated, mimicking a polymorphic malware
# Now the actual code/payload will be located in here
#Start
puts "Hello World!"
#End

encryptor(key)

#Start
puts "I can en/decrypt multiple lines of code at multiple locations!"
puts "I don't think you've seen the secret message inside my code..."
#End

# The next line is for exclusively updating the file to encrypt the payload with new ciphertext
at_exit do
	File.open(File.basename(__FILE__), "w+") do |i|
		i.puts($f_data)
	end
end
