// § tpOwnTsAtHeaderDefault188
package p;
  class c #(type T = int, int W = 4);
    T p;
    bit [W-1:0] w;
  endclass
  // c #(int, 8) h1;
  // c #(int) h2;
endpackage
module top;
  p::c #(int) h1;
  p::c h2;
endmodule
