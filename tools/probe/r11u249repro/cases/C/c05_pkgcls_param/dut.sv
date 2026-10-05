// § clsTdArrElemPkgPath249
package p;
  localparam int N = 3;
  class c;
    typedef int f_t[N];
    f_t m_f;
  endclass
endpackage
module top;
  import p::*;
  c o;
endmodule
