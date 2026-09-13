// b2 — b1's BAIL twin.  `mk` never writes member `U`, so the v1.87 assembler
// gives up on the base and the param_assign Rhs STAYS a struct_var; every site
// must then be left exactly as the pristine binary emits it (BYTE-IDENTICAL).
package p;
  typedef struct packed {
    int unsigned A;
    int unsigned B;
    int unsigned U;                   // never written by the builder
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
  holder #(.H(p::C)) u1();
  holder #(.H(D))    u2();
endmodule

module holder
  import p::*;
#(parameter cfg_t H = '0) ();
endmodule
