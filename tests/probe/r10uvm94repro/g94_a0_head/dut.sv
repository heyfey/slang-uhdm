// r10uvm94 arm a0 -- the SEVEN-ROW-MODE UVM HEAD, reproduced in 19 lines.
// Golden's cmp head on this file is BYTE-FOR-BYTE the 164-line head the seven
// UVM row-modes carry at uvm_object_defines.svh:3674 (the uvm_unpack_enumN
// macro body, packer.m_bits[packer.count +: SIZE]).  PRISTINE: CMP_FAIL, 1 head,
// 164 cmp lines.  PATCHED: PASS_CMP.  MEASUREMENT-ONLY.
class pk94;
  bit [4095:0] m_bits;
  int count;
endclass
class ob94;
  int fld;
  function void unp(pk94 packer);
    logic [31:0] v;
    int lo;
    { << { v }} = packer.m_bits[packer.count +: 32];
    v = packer.m_bits[lo +: 16];
    v = packer.m_bits[7 +: 8];
    v = packer.m_bits[lo -: 8];
    v = packer.m_bits[packer.count -: 4];
    v = packer.m_bits[lo + 2 +: 8];
    v = packer.m_bits[31 : 0];
    v = packer.m_bits[lo];
  endfunction
endclass
