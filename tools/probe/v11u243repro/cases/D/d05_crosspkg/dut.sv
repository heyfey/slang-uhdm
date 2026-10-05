// § clsPropLawSAliasName243
// a class in a second package with properties of the first package's typedefs, qualified and imported
package p;
  typedef int i_t;
  typedef longint g_t;
endpackage
package q;
  import p::*;
  class c;
    i_t m_i;
    p::g_t m_g;
    integer m_plain;
  endclass
endpackage
module top;
  q::c o;
endmodule
