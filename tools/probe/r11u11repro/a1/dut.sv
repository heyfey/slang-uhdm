// a1 — PACKAGE holder, base ASSEMBLES, WILDCARD import, one member 1024 bits.
// Four site kinds in one design:
//   S1 member select of the base as an override actual      (R0)
//   S2 BARE REFERENCE to the base as an override actual     (R2)
//   S3 module parameter DEFAULTED to the base               (R3)
//   S4 the wildcard-import copy's own param_assign Rhs      (V1)
package p;
  typedef struct packed {
    int unsigned       A;
    int unsigned       B;
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
  parameter cfg_t D = p::C;          // S3
  leaf   #(.W(C.B))  u1();           // S1
  holder #(.H(p::C)) u2();           // S2
endmodule

module leaf #(parameter int unsigned W = 2) ();
endmodule

module holder
  import p::*;
#(parameter cfg_t H = '0) ();
endmodule
