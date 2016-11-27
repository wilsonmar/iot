#

# 1. make sure sudo is provided, or abort.
# 2. extract the sd card drive spec for input file
# 3. compose the output file 
# 4. Make sure there is enough disk space on output drive, or abort.
# 5. Prompt to confirm
# 6. run dd 

import subprocess

command = ['ls', '-l']
p = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess)
text = p.stdout.read()
retcode = p.wait()