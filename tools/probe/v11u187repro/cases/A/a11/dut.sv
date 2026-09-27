// § aliasFoldBoundFile183 (the target typedef in an included file inside the package)
package p;
`include "t.svh"
typedef imm_i_t imm_l_t;
typedef struct packed { imm_l_t imm; logic [3:0] op; } ctl_t;
endpackage
module top import p::*; (input ctl_t a, output logic [11:0] o);
  assign o = a.imm;
endmodule
