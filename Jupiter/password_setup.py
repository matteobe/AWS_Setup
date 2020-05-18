# File used for password setup for Jupiter notebooks
from sys import argv
from IPython.lib import password

script, mypasswd = argv

# Launch the command using the argument passed in and return a SHA1 key
print passwd(mypasswd)
