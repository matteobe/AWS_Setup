# File used for password setup for Jupiter notebooks
from sys import argv
from IPython.lib import passwd

script, mypasswd = argv

# Launch the command using the argument passed in and return a SHA1 key
shak = passwd(mypasswd)

# Write SHA key to file
f = open('sha_key.txt','w+')
f.write(shak)
f.close()
