module std::core::mem::allocators @feat(FREESTANDING_WASM);
import std::core::mem::alloc;
import std::core::builtin;
import std::core::mem;

WasmArena{0} wasm_mem = { .top = mem::WASM_HEAP_BASE };

<*
 Arena allocator automatically expanding the webassembly memory when necessary.
 <WASM_MEMORY> defines the instance of webassembly memory that the arena is in.

 @require $Typeof(WASM_MEMORY)::kind == SIGNED_INT
*>
struct WasmArena (Allocator) <WASM_MEMORY>
{
	void* top;
}

<*
 @return? builtin::@wasm_memory_grow!
*>
fn void*? WasmArena.acquire(&self, sz size, AllocInitType init_type = ZERO, sz alignment = 0) @dynamic
{
	sz extra_alignment = self.top % alignment;
	sz byte_sum = bytes + self.top + extra_alignment;
	usz allocated_bytes = @wasm_memory_size(WASM_MEMORY) * mem::WASM_BLOCK_SIZE;
	if(byte_sum > allocated_bytes)
	{
		sz blocks_required = (sz)((byte_sum - allocated_bytes) / mem::WASM_BLOCK_SIZE);
		@wasm_memory_grow(blocks_required, WASM_MEMORY)!;
	}
	if(init_type == ZERO)
	{
		mem::set((void*)byte_sum, 0, (usz)bytes);
	}
	defer self.top = byte_sum;
	return self.top + extra_alignment;
}
fn void*? WasmArena.resize(&self, void* ptr, sz new_size, sz alignment = 0) @dynamic
{
	self.acquire(new_size, ZERO, alignment);
}
<* Rewinds the top of the WasmArena to the given marker *>
fn void WasmArena.release(&self, void* marker, bool aligned = false) @dynamic
{
	self.top = marker;
}
<* Sets the start of the WasmArena to the given start pointer *>
fn void WasmArena.init(&self, void* start)
{
	self.top = start;
}
<* An arena pool on WasmArena *>
macro @wasm_pool(WasmArena pool = wasm_mem; @body()) 
{
	void* marker = pool.top;
	@body();
	pool.release(marker);
}