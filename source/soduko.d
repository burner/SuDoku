module soduko;

import std.stdio;

bool usedInRow(const ref ushort[9][9] field, 
		const ushort num, const ushort row) @safe @nogc
{
	for(size_t i = 0; i < 9; ++i) {
		//debug writefln("uir %d %d", row, i);
		if(field[row][i] == num) {
			return true;
		}
	}
	return false;
}

bool usedInColumn(const ref ushort[9][9] field, 
		const ushort num, const ushort column) @safe @nogc
{
	for(size_t i = 0; i < 9; ++i) {
		//debug writefln("uic %d %d", i, column);
		if(field[i][column] == num) {
			return true;
		}
	}
	return false;
}

bool usedInBlock(const ref ushort[9][9] field, const ushort num, 
		const ushort row, const ushort column) @safe @nogc
{
	for(size_t r = row; r < row + 3; ++r) {
		for(size_t c = column; c < column + 3; ++c) {
			//debug writefln("uib %d %d", r, c);
			if(field[r][c] == num) {
				return true;
			}
		}
	}
	return false;
}

bool isNotUsed(const ref ushort[9][9] field, const ushort num, 
		const ushort row, const ushort column) @safe
{
	import std.conv : to;
	import std.stdio : writefln;
	ushort blockRow = cast(ushort)(row - row % 3);
	ushort blockCol = cast(ushort)(column - column % 3);
	//writefln("c %d %d %d %d", row, column, blockRow, blockCol);
	return !usedInColumn(field, num, column)
		&& !usedInRow(field, num, row)
		&& !usedInBlock(field, num, blockRow, blockCol);
}

unittest {
	Soduko t;
	t.field = [
		[5,3,0,6,7,8,9,1,2],
		[6,7,2,1,9,5,3,4,8],
		[1,9,8,3,4,2,5,6,7],
		[8,5,9,7,6,1,4,2,3],
		[4,2,6,8,5,3,7,9,1],
		[7,1,3,9,2,4,8,5,6],
		[9,6,1,5,3,7,2,8,4],
		[2,8,7,4,1,9,6,3,5],
		[3,4,5,2,8,6,1,7,9]
	];
	assert(isNotUsed(t.field, 4, 0, 2));

	ushort row;
	ushort column;

	assert(findUnassignedLocation(t.field, row, column));
	assert(row == 0);
	assert(column == 2);
}


bool findUnassignedLocation(const ref ushort[9][9] field,
		ref ushort row, ref ushort column) @safe nothrow @nogc
{
	for(ushort r = 0; r < 9; ++r) {
		for(ushort c = 0; c < 9; ++c) {
			if(field[r][c] == 0) {
				row = r;
				column = c;
				return true;
			}
		}
	}
	return false;
}

static bool solve2Back(ref ushort[9][9] field) @safe {
	//writefln("%(%(%s %)\n%)", field);

	ushort row;
	ushort col;
 
	if(!findUnassignedLocation(field, row, col)) {
		return true;
	}

	for(ushort num = 1; num <= 9; num++) {
		if(isNotUsed(field, num, row, col)) {
			field[row][col] = num;
 
			if(solve2Back(field)) {
				return true;
			}
 
			field[row][col] = 0;
		}
	}
	return false;
}

pragma(msg, typeof(solve2Back));

struct Soduko {
	ushort[9][9] field;

	bool solve() {
		bool ret = solve2Back(this.field);		
		if(!ret) {
			return ret;
		}

		return this.test();
	}

	void print() @safe {
		import std.stdio : writefln;
		for(size_t i = 0; i < 9; ++i) {
			if(i % 3 == 0) {
				writeln("---------------------");
			}
			for(size_t j = 0; j < 9; ++j) {
				if(j && j % 3 == 0) {
					write("| ");
				}
				writef("%d ", this.field[i][j]);
			}
			writeln();
		}
		writeln("---------------------");
	}

	bool testRow(size_t row) const nothrow @safe @nogc {
		bool[10] values;
		for(size_t i = 0; i < this.field.length; ++i) {
			if(this.field[row][i] == 0 || values[this.field[row][i]]) {
				return false;
			}
			values[this.field[row][i]] = true;
		}
		return true;
	}

	bool testRows() const nothrow @safe @nogc {
		for(size_t i = 0; i < this.field.length; ++i) {
			if(!this.testRow(i)) {
				return false;
			}
		}
		return true;
	}

	bool testColumn(size_t col) const nothrow @safe @nogc {
		bool[10] values;
		for(size_t i = 0; i < this.field.length; ++i) {
			if(this.field[i][col] == 0 || values[this.field[i][col]]) {
				return false;
			}
			values[this.field[i][col]] = true;
		}
		return true;
	}

	bool testColumns() const nothrow @safe @nogc {
		for(size_t i = 0; i < this.field.length; ++i) {
			if(!this.testColumn(i)) {
				return false;
			}
		}
		return true;
	}

	bool testBlock(const size_t row, const size_t col) const nothrow @safe @nogc {
		bool[10] values;
		for(size_t r = row * 3; r < (row + 1) * 3; ++r) {
			for(size_t c = col * 3; c < (col + 1) * 3; ++c) {
				if(this.field[r][c] == 0 || values[this.field[r][c]]) {
					return false;
				}
				values[this.field[r][c]] = true;
			}
		}
		return true;
	}

	bool testBlocks() const nothrow @safe @nogc {
		for(size_t r = 0; r < 3; ++r) {
			for(size_t c = 0; c < 3; ++c) {
				if(!this.testBlock(r,c)) {
					return false;
				}
			}
		}
		return true;
	}

	bool test()  const nothrow @safe @nogc {
		return this.testRows() && this.testColumns() && this.testBlocks();
	}
}

unittest {
	Soduko t;
	assert(!t.testRows());
}

unittest {
	Soduko t;
	t.field[0][0] = 1;
	t.field[0][1] = 2;
	t.field[0][2] = 3;
	t.field[0][3] = 4;
	t.field[0][4] = 5;
	t.field[0][5] = 6;
	t.field[0][6] = 7;
	t.field[0][7] = 8;
	t.field[0][8] = 9;
	assert(t.testRow(0));
	assert(!t.testRows());
}

unittest {
	Soduko t;
	t.field[0][0] = 1;
	t.field[0][1] = 2;
	t.field[0][2] = 3;
	t.field[0][3] = 4;
	t.field[0][4] = 5;
	t.field[0][5] = 6;
	t.field[0][6] = 7;
	t.field[0][7] = 9;
	t.field[0][8] = 9;
	assert(!t.testRow(0));
	assert(!t.testRows());
}

unittest {
	Soduko t;
	assert(!t.testColumns());
}

unittest {
	Soduko t;
	t.field[0][0] = 1;
	t.field[1][0] = 2;
	t.field[2][0] = 3;
	t.field[3][0] = 4;
	t.field[4][0] = 5;
	t.field[5][0] = 6;
	t.field[6][0] = 7;
	t.field[7][0] = 8;
	t.field[8][0] = 9;
	assert(t.testColumn(0));
	assert(!t.testColumns());
}

unittest {
	Soduko t;
	t.field[0][0] = 1;
	t.field[1][0] = 2;
	t.field[2][0] = 2;
	t.field[3][0] = 4;
	t.field[4][0] = 5;
	t.field[5][0] = 6;
	t.field[6][0] = 7;
	t.field[7][0] = 8;
	t.field[8][0] = 9;
	assert(!t.testColumn(0));
	assert(!t.testColumns());
}

unittest {
	Soduko t;
	assert(!t.testBlocks());
}

unittest {
	Soduko t;
	t.field[0][0] = 1;
	t.field[0][1] = 2;
	t.field[0][2] = 3;
	t.field[1][0] = 4;
	t.field[1][1] = 5;
	t.field[1][2] = 6;
	t.field[2][0] = 7;
	t.field[2][1] = 8;
	t.field[2][2] = 9;
	assert(t.testBlock(0,0));
	assert(!t.testBlocks());
}

unittest {
	Soduko t;
	t.field = [
		[5,3,4,6,7,8,9,1,2],
		[6,7,2,1,9,5,3,4,8],
		[1,9,8,3,4,2,5,6,7],
		[8,5,9,7,6,1,4,2,3],
		[4,2,6,8,5,3,7,9,1],
		[7,1,3,9,2,4,8,5,6],
		[9,6,1,5,3,7,2,8,4],
		[2,8,7,4,1,9,6,3,5],
		[3,4,5,2,8,6,1,7,9]
	];

	assert(t.test());

	t.field = [
		[6,7,2,1,9,5,3,4,8],
		[5,3,4,6,7,8,9,1,2],
		[1,9,8,3,4,2,5,6,7],
		[8,5,9,7,6,1,4,2,3],
		[4,2,6,8,5,3,7,9,1],
		[7,1,3,9,2,4,8,5,6],
		[9,6,1,5,3,7,2,8,4],
		[2,8,7,4,1,9,6,3,5],
		[3,4,5,2,8,6,1,7,9]
	];

	assert(t.test());

	t.field = [
		[6,7,2,9,1,5,3,4,8],
		[5,3,4,7,6,8,9,1,2],
		[1,9,8,4,3,2,5,6,7],
		[8,5,9,6,7,1,4,2,3],
		[4,2,6,5,8,3,7,9,1],
		[7,1,3,2,9,4,8,5,6],
		[9,6,1,3,5,7,2,8,4],
		[2,8,7,1,4,9,6,3,5],
		[3,4,5,8,2,6,1,7,9]
	];

	assert(t.test());
}

unittest {
	Soduko t;
	t.field = [
		[5,3,4,6,7,8,9,1,2],
		[6,7,2,1,9,5,3,4,8],
		[1,9,8,3,4,2,5,6,7],
		[8,5,9,7,6,1,4,2,3],
		[4,2,6,8,5,3,7,9,1],
		[7,1,3,9,2,4,8,5,6],
		[9,6,1,5,3,7,2,8,4],
		[2,8,7,4,1,9,6,3,5],
		[3,4,5,2,6,8,1,7,9]
	];

	assert(!t.test());
}

unittest {
	import std.stdio;
	Soduko t;
	t.field = [
		[0,3,0,0,0,0,0,0,0],
		[0,0,0,1,9,5,0,0,0],
		[0,0,8,0,0,0,0,6,0],
		[8,0,0,0,6,0,0,0,0],
		[4,0,0,8,0,0,0,0,1],
		[0,0,0,0,2,0,0,0,0],
		[0,6,0,0,0,0,2,8,0],
		[0,0,0,4,1,9,0,0,5],
		[0,0,0,0,0,0,0,7,0]
	];
	t.solve();
	writefln("%(%(%s %)\n%)", t.field);
}
