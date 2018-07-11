import std.stdio;

void main() {
	import soduko;

	Soduko t;

	writeln("Enter each row of your soduko one line at a time.");
	writeln("Numbers need to be seprated by one whitespace.");
	writeln("Empty places are inserted by the number 0");
	for(size_t i = 0; i < 9; ++i) {
		readf("%d %d %d %d %d %d %d %d %d\n",
			t.field[i][0], t.field[i][1], t.field[i][2], 
			t.field[i][3], t.field[i][4], t.field[i][5], 
			t.field[i][6], t.field[i][7], t.field[i][8]);
	}

	writeln("Soduko to solve");
	t.print();
	writeln("starting solve");
	if(!t.solve()) {
		writeln("The soduko couldn't be solved");
	} else {
		writeln("The solved soduko");
		t.print();
	}
}
