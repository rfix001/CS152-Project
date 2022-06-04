
    |rse: miniL.lex miniL.y
	bison -v -d --file-prefix=y miniL.y
	flex miniL.lex
	gcc -o miniL y.tab.c lex.yy.c -lfl

clean:
	rm -f lex.ff.c y.tab.* y.output *.o miniL error END {printf("Oops\n");}
