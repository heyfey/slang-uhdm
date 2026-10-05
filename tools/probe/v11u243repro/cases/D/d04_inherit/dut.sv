// § clsPropLawSAliasName243
// a base and a derived class each with a property of the same typedef, and a nested class
package p;
  typedef shortint s_t;
  class b;
    s_t m_b;
  endclass
  class d extends b;
    s_t m_d;
    class n;
      s_t m_n;
    endclass
  endclass
endpackage
module top;
  import p::*;
  d o;
endmodule
