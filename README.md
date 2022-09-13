# Hello-Virus

This piece of code is an introduction to how malwares (more specifically, viruses) work. The example is done entirely in Ruby and commented wherever necessary to help you understand and replicate it in any other language you desire.

# Background
A virus is a type of malware that, upon execution, infects the system it is on with an encrypted and sensitive code designed to harm entire system through various methodologies. Three types of viruses are commonly devised and distributed in the wild web:
- Oligomorphic virus: these kind of viruses tend to have an encrypted sequence of code (encrypted segment) with a key known only to the executable, and a set of keys used for decryption (let's call this the decryptor segment). The encrypted and decrypted segments are piled onto one another alongside the main executable. It can be either at the beginning of the file, in the middle disjointed, or at the very end - or perhaps a combination. What happens is, upon execution, the virus picks up the stored key and uses it to decrypt the encrypted part of the code required for infecting the system. Once it has decrypted the code, the virus executes the commands, with or without the main program's commands. Once it is terminating, the virus picks up a random key from the set of keys in the decryptor segment and uses it to re-encrypt the sensitive part of the code, all the while storing the new key inside itself for decryption upon executing again.
- Polymorphic virus: much like Oligomorphic viruses, they have decryptor and encrypted segments, and generally behave the same way. Unlike Oligomorphic viruses, however, Polymorphic viruses produce a completely random key for encryption of the sensitive code every time it executes. This makes it difficult to decipher the sensitive code, unlike Oligomorphic viruses, where the virus will mutate according to a set of keys - here, anything goes.
- Metamorphic virus: by far the most dangerous of the bunch, metamorphic viruses take Polymorphic viruses to the next level where, apart of producing a new key for deciphering the sensitive code every time, the code **ITSELF** changes upon executon every time - upon execution, the new code will look nothing like the original code, yet the behavioural characteristics of the code remain the same (in other words, changed syntactically but not semantically). This makes the virus extremely difficult to root out of the executable and patch out.

How do antiviruses combat this? Each executable has a file signature that is, in Layman terms, computed on the basis of what binary data is present inside the executable. Changing just one byte will cause the executable's file signature to change. For Oligomorphic viruses, once all keys are identified, the signature generated from the infected executable can easily be traced. Polymorphic viruses' key generation routine also needs to be deciphered for it to actually be detected by antiviruses as well. Metamorphic viruses are difficult to combat in essence because of their ability to change the code during runtime.

# Build Details
This program is done (as explained before) in Ruby, but there are other details to note:
- Version compiled and executed on: 3.1.1p18 (2022-02-18 revision 53f5fc4236)
- Type of virus exhibited by the file: Polymorphic
- Key generation: arbitrary (alphanumeric, case-insensitive string of arbitrary length from 1 to 65536)
- Encryption algorithm(s) used: AES-256 (Counter mode)
- Hashing algorithm(s) used: MD5
- Encoding algorithm(s) used: Base64
- Modules used for the specified algorithms:
  - OpenSSL (for AES-256 CTR)
  - Digest (for MD5)
  - Base64 (for - well, Base64)

# Process
Here's what's happening under the hood:
- The program starts and searches for a key. If the key is present, it gathers all of the driver code present inside itself and decrypts it using the key. The decrypted line of code is now executed through the process of metaprogramming (a really interesting way to program! I suggest you look it up here: https://en.wikipedia.org/wiki/Metaprogramming). The program executes as normal if no key is present for now.
- Once the payload (from here on out, I'll call code "payload") has been executed and the end of program has been reached, the payload is then copied over and passed through a multi-layered encryption process to encrypt the payload necessary to execute (whether for beneficial or nefaiours purposes, that's up to debate). The final cipher text is now overwitten in place of the original code and at the end, the entire file is rewritten to preserve the information. The key used to encrypt the information is also saved as it will be required when the program executes the next time.

Keep in mind that the key stored here is pretty simple, and in most cases, the key itself is hidden inside a virus pretty well. The process here is pretty simple just to get you on a page of how viruses work in general.

# Encryption/Decryption
I'll be absolutely honest with you - what I've done regarding encryption is utterly mindless, but I just wanted to experiment with the libraries themselves as well. Regardless, I am obliged to show you the procedure of how I encrypted my data:
- The program generates an alphanumeric string (case-insensitive) of an arbitrary/random size between length 1 and 65536 characters. This key is stored as it is the basis for encryption and decryption of the payload.
- The key is passed through an MD5 hash algorithm to generate a 32-characters long Hex string hash (the hash length is important for the next step).
- The hash produced from the MD5 algorithm is now passed through the AES-256 encryption algorithm (CTR mode, as it helps us *kind of* ignore the padding required for the cipher text), along with the plaintext (which in our case, for example, would be `puts "Hello World!"`), and the byte string generated from it is now stored as a cipher text.
- Since the cipher text is unreadable, it is passed through one more algorithm (an encoding one), the Base64 encoding algorithm, to generate a long readable string, which finally replaces the line of code we encrypted in the first place.

# Closing
The code is untidy, it took me days to get an understanding of the different algorithms I could utilize, and how I wanted to achieve this in a single file *(not to mention getting through metalprogramming and the consequences of the* ***eval*** *function)* - but all in all, I had a fun time completing this mini-project. I aim to improve this demonstration down the line someday, so be on the lookout for this repository.
I hope you had fun romping through the example and, more importantly, it gave you an idea of how viruses work in general. I solely own this project, but you are free to use (and credit, if you'd like) wherever you feel this would help in any sort of scenario.

