// b5 — b1 with an EXPLICIT import (`import p::C;`) instead of the wildcard.
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
  import p::C;
  import p::cfg_t;
();
  parameter cfg_t D = p::C;
  holder #(.H(p::C)) u1();
  holder #(.H(D))    u2();
endmodule

module holder
  import p::cfg_t;
#(parameter cfg_t H = '0) ();
endmodule
