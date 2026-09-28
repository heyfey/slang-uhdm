// § modPkgGenericSpecNamedBare202
package q;
  localparam int W = 6;
endpackage
package p;
  class C #(parameter int W = 4);
    logic [W-1:0] v;
  endclass
  typedef C #(5) c5_t;
endpackage
module top;
  p::C #(q::W) h1;
  p::c5_t h2;
  p::C #(q::W + 1) h3 = new;
endmodule
