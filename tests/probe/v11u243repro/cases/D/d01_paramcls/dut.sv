// § clsPropLawSAliasName243
// a parameterized class's properties of package typedefs with two specializations
package p;
  typedef int i_t;
  typedef logic [7:0] l_t;
  class pc #(int W = 2);
    i_t m_i;
    l_t m_l;
    function int go(); return m_i + W; endfunction
  endclass
endpackage
module top;
  import p::*;
  pc #(4) a;
  pc #(5) b;
  int x;
  initial begin a = new; x = a.go(); end
endmodule
