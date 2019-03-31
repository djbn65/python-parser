### To run:
```
flex *.l
bison *.y
g++ *.tab.c -o parser
./parser < inputFileName
```
