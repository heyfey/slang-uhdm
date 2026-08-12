// r10uvm61 ARM c3_sibling — does the class-body fold c1 found apply to the
// OTHER type-query system functions, or only to $bits?  Same class, same
// member, same in-block method; only the FUNCTION changes.
package c3_pkg;

  class sib_c;
    logic [7:0]  m_pk;
    bit          m_arr[4];
    int          m_i;

    function void r(ref int o);
      o = $bits(m_pk);        // the known-folding baseline
      o = $size(m_arr);
      o = $size(m_pk);
      o = $clog2(m_i);
      o = $high(m_pk);
      o = $low(m_pk);
      o = $left(m_pk);
      o = $right(m_pk);
      o = $countones(m_pk);
      o = $dimensions(m_arr);
      o = $unpacked_dimensions(m_arr);
      o = $increment(m_pk);
      o = $typename(m_pk).len();
      o = $isunknown(m_pk);
    endfunction
  endclass

  // CONTROL: the same list in an OUT-OF-BLOCK body, where c1 says $bits does
  // NOT fold.  If a sibling folds here but $bits does not, the discriminator
  // is per-FUNCTION, not per-CONTEXT.
  class sib_oob_c;
    logic [7:0]  m_pk;
    bit          m_arr[4];
    int          m_i;
    extern function void r(ref int o);
  endclass

  function void sib_oob_c::r(ref int o);
    o = $bits(m_pk);
    o = $size(m_arr);
    o = $size(m_pk);
    o = $clog2(m_i);
    o = $high(m_pk);
    o = $low(m_pk);
    o = $left(m_pk);
    o = $right(m_pk);
    o = $countones(m_pk);
  endfunction

endpackage

module c3_top;
  import c3_pkg::*;
  int o;
  initial begin
    sib_c a = new(); sib_oob_c b = new();
    a.r(o); b.r(o);
  end
endmodule
