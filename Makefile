default:
	flex *.l
	bison *.y -v
	g++ *.tab.c -o parser

run: default
	./parser