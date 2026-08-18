// r10uvm95 — THE HEAD, in 30 lines.  uvm-1.2 `uvm_record_int` passes
// SIZE = `$bits(m_data[i])` where `m_data` is `rand byte unsigned m_data[]`,
// and the macro body writes `if (SIZE > 64)`.  Golden FOLDS that to a LOCATED
// constant carrying the ROOT array's width (8 — an unsized dimension counts
// as ONE), we kept the `sys_func_call`.
//
// The cells are deliberately NOT self-confirming: the same method also asks
// for a FIXED-size array (`m_fix[4]` -> 32, NOT 8), a packed vector under a
// bit-select (`m_vec[i]` -> 24, NOT 1) and a plain member (`m_len` -> 32),
// and the widths, the names and the element types all differ.
`define rec95(NAME, VALUE, SIZE) \
    if (SIZE > 64) \
      sink95(NAME, VALUE, SIZE); \
    else \
      sink95(NAME, VALUE, SIZE);

package p95head;
  class payload95;
    rand byte unsigned m_data [];
    bit [5:0]          m_fix  [4];
    bit [23:0]         m_vec;
    int unsigned       m_len;
    function void sink95(string n, int unsigned v, int unsigned sz); endfunction
    function void do_record95();
      for (int i = 0; i < m_len; i++)
        `rec95($sformatf("\\data[%0d] ", i), m_data[i], $bits(m_data[i]))
      for (int i = 0; i < m_len; i++)
        `rec95($sformatf("\\fix[%0d] ", i), m_fix[i], $bits(m_fix[i]))
      sink95("vec", m_vec[3], $bits(m_vec[3]));
      sink95("len", m_len, $bits(m_len));
    endfunction
  endclass
endpackage
