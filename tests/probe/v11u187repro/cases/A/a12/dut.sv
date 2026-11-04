// § aliasFoldBoundFile183 (the alias in an included file, the target in the root file, a W-1 bound)
package p;
localparam int W = 8;
typedef logic [W-1:0] imm_i_t;
`include "t.svh"
typedef struct packed { imm_l_t imm; logic [3:0] op; } ctl_t;
endpackage
module top import p::*; (input ctl_t a, output logic [7:0] o);
  imm_l_t v;
  assign v = a.imm;
  assign o = v;
endmodule
