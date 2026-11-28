module const_struct_member_fold @test;

struct Anon { struct { int lo; } union { int ui; char[4] uc; } }
const Anon A = { .ui = 0x01020304 };
struct Anon2 { struct { int lo; } int ui; }
const Anon2 A2 = { .ui = 42 };
struct Deep { union { struct { int x; int y; } long l; } }
const Deep D = { .y = 9 };

fn void member_after_zero_anonymous_struct()
{
	int $v = A2.ui;
	assert($v == 42);
	assert(A2.ui == 42);
	assert(A2.lo == 0);
}

fn void member_in_anonymous_union()
{
	assert(A.ui == 0x01020304);
	assert(A.lo == 0);
}

fn void struct_inside_anonymous_union()
{
	int $y = D.y;
	assert($y == 9);
	assert(D.y == 9);
	assert(D.x == 0);
}

fn void inactive_union_member_with_const_index() @feat(!BIG_ENDIAN)
{
	assert(A.uc[1] == 3);
	assert(A.uc[3] == 1);
}
