// § clsPropLawSAliasName243
// class properties typed by package typedefs of int, logic vector, bit, byte and string, read by a method
package p;
  typedef int i_t;
  typedef logic [7:0] l_t;
  typedef bit b_t;
  typedef byte y_t;
  typedef string s_t;
  class c;
    i_t m_i;
    l_t m_l;
    b_t m_b;
    y_t m_y;
    s_t m_s;
    function int go(); return m_i + m_l + m_b + m_y + m_s.len(); endfunction
  endclass
endpackage
module top;
  import p::*;
  int x;
  initial begin c o = new; x = o.go(); end
endmodule
