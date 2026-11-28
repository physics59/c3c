module std::core::mem::allocators;


const sz WASM_BLOCK_SIZE = 65536;

WasmMemory wasm_memory @deprecated("Use wasm_mem instead");

struct WasmMemory @deprecated("Use WasmArena instead")
{
	sz allocation;
	sz use;
}

fn char[]? WasmMemory.allocate_block(&self, sz bytes) @deprecated("Use WasmArena.acquire instead")
{
	if (!self.allocation)
	{
		self.allocation = $$wasm_memory_size(0) * WASM_BLOCK_SIZE;
	}
	sz bytes_required = bytes + self.use - self.allocation;
	if (bytes_required <= 0)
	{
		defer self.use += bytes;
		return ((char*)self.use)[:bytes];
	}

	sz blocks_required = (bytes_required + WASM_BLOCK_SIZE - 1) / WASM_BLOCK_SIZE;
	if ($$wasm_memory_grow(0, blocks_required) == -1) return mem::OUT_OF_MEMORY~;
	self.allocation = $$wasm_memory_size(0) * WASM_BLOCK_SIZE;
	defer self.use += bytes;
	return ((char*)self.use)[:bytes];
}