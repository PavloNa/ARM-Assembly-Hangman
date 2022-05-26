# ARM-Assembly-Hangman
This is an ARM Assembly game designed in Rapberry PI
If you wish to play just run "./hangman" wherever you save the files.

#EDIT FILE  nano hangman.s
#COMPILE AND RUN
as -g -o hangman.o hangman.s
gcc -g -o hangman hangman.o
./hangman
