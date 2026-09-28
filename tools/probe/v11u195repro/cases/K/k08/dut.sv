// § procNetMidSelDotted195 — v11u195 fresh: a case expression and a case item body on net-based mid selects
package rp;
  typedef struct packed { logic [3:0] q; logic qe; } key_t;
  typedef struct packed { key_t [3:0] key; logic [3:0] ctrl; } reg2hw_t;
endpackage
module top(input rp::reg2hw_t reg2hw, input logic [1:0] i, output logic [3:0] o);
  always_comb
    case (reg2hw.key[i].q)
      4'h1: o = reg2hw.key[0].q;
      default: o = 4'h0;
    endcase
endmodule
