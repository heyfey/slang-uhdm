// § specValueArgRefObj470
package p;
  class C #(int W = 8, int D = 8);
    int x;
  endclass
endpackage
package t;
  import p::*;
  class E;
    localparam w = 16; localparam d = 32;
    C #(w, d) h;
  endclass
endpackage
module top; import t::*; E e; endmodule
