// § castPatTagKeyLocThroughParens302
// vc01: a parenthesized pattern with no cast as a localparam initializer and in a continuous assignment
package p;
  typedef struct packed { int unsigned n; logic [15:0] h; } cfg_t;
endpackage
module dut (output p::cfg_t o);
  localparam p::cfg_t P = ('{n: 9, h: 16'h00AB});
  assign o = ('{n: P.n, h: 16'h1});
endmodule
