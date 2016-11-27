import subprocess
text = '"Hello world"'
subprocess.call('echo '+text+'|festival --tts', shell=True)

text = '"You are listening to text to speech synthesis using Festival package from the University Edingburg in the UK."'
filename = 'hello'
file=open(filename,'w')
file.write(text)
file.close()
subprocess.call('festival --tts '+filename, shell=True)
