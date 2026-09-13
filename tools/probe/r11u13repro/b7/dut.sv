// b7 — THE CHAIN and THE RE-PASS.  `E = D = p::C` is two bare-reference hops
// from the assembled base, and `mid` hands its own formal to a grandchild.
package p;
  typedef struct packed {
    int unsigned A;
    int unsigned B;
    logic [15:0][63:0] WIDE;
  } cfg_t;
  function automatic cfg_t mk(input bit e);
    cfg_t c;
    c.WIDE = {16{64'h0}};
    c.A = 32;
    c.B = e == 1'b1 ? (c.A / 16) : 1;
    return c;
  endfunction
  localparam cfg_t C = mk(1'b1);
endpackage

module top
  import p::*;
();
  parameter cfg_t D = p::C;
  parameter cfg_t E = D;              // the second hop
  mid #(.M(E)) u1();
endmodule

module mid
  import p::*;
#(parameter cfg_t M = '0) ();
  leaf #(.L(M)) u2();                 // THE RE-PASS: a formal handed down
endmodule

module leaf
  import p::*;
#(parameter cfg_t L = '0) ();
endmodule
