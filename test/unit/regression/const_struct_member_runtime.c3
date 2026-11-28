module const_struct_member_runtime @test;

struct Anon { struct { int lo; } union { int ui; char[4] uc; } }
const Anon A = { .ui = 0x01020304 };
struct Tab { int[4] a; Anon[2] anons; }
const Tab T = { { 1, 2, 3, 4 }, { { .ui = 5 }, { .ui = 6 } } };

fn void runtime_index_reads_constant()
{
	int i = 2;
	assert(T.a[i] == 3);
	assert(T.anons[i - 1].ui == 6);
	assert(T.anons[i - 2].lo == 0);
	int sum;
	foreach (x : T.a) sum += x;
	assert(sum == 10);
}

fn void inactive_union_member_reads_bytes() @feat(!BIG_ENDIAN)
{
	int i = 1;
	assert(A.uc[i] == 3);
}
