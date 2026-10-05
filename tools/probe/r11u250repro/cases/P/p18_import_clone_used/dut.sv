// § pkgArrTdImportClone250
package a;
  typedef logic [3:0] b_t[0:1];
  typedef int q_t[];
endpackage
package p;
  import a::*;
  class c;
    b_t m_b;
    q_t m_q;
  endclass
endpackage
module top;
  import a::*;
  import p::*;
  b_t x;
  q_t y;
  c o;
endmodule
