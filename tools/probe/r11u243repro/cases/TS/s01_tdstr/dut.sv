// § lawSStringTd243
// a class property typed by a package typedef of string
package p;
  typedef string str_t;
  class b;
    str_t m_al;
    function int go(); return m_al.len(); endfunction
  endclass
endpackage
module top;
  import p::*;
  int x;
  initial begin b o = new; x = o.go(); end
endmodule
