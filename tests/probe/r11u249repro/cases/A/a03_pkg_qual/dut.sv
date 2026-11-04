// § clsPropWholeArrTd249
package a;
  typedef logic [7:0] v_t[0:3];
endpackage
package p;
  class c;
    a::v_t m_v;
    static a::v_t s_v;
  endclass
endpackage
module top;
  import p::*;
  c o;
endmodule
