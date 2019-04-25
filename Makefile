default:
	flex *.l
	bison *.y -v
	g++ *.tab.c -o parser --std=c++17

run: default
	./parser