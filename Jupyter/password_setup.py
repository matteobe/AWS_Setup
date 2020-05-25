# File used for password setup for Jupiter notebooks
from IPython.lib import passwd

# Launch the command using the argument passed in and return a SHA1 key
shak = passwd()

# Write SHA key to file
f = open('sha_key.txt','w+')
f.write(shak)
f.close()
