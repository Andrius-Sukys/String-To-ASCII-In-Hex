The program converts a given string's symbols one by one to their respective ASCII codes in hexadecimal format, e.g. abC1 turns into 61 62 43 31.

To RUN the program, [TASM](https://klevas.mif.vu.lt/~linas1/KompArch/TASM.zip) & [DosBox](https://sourceforge.net/projects/dosbox/) are required.

To LAUNCH and use the program:
1) Put the project file inside TASM's installation folder.
2) Start up DosBox.
3) Enter these commands in this exact sequence:
```
mount c: *tasm installation folder's location* (for example, mount c: d:/tasm)
c:
tasm Hex.asm
tlink Hex.obj
Hex.exe
```
The User will then be promped to enter a string – "Enter a string to convert its symbols to hexadecimal ASCII format".
Once the string has been entered, press Enter. Output with the result will be displayed.

Example:
```
Enter a string to convert its symbols to hexadecimal ASCII format:
abC1 [User's input]
The Result:
61 62 43 31
```
