// § clsPropWholeArrTd249
package p;
  typedef int q_t[$];
  typedef bit [3:0] d_t[];
  class c;
    q_t m_q;
    local d_t m_d;
  endclass
endpackage
module top;
  import p::*;
  c o;
endmodule
