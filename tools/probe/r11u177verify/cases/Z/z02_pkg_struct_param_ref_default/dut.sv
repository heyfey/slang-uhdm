// § ppOutputFile166 § aggFoldReanchorFile177v
`include "defs.svh"
package p;
  typedef struct packed { int unsigned A; int unsigned B; } cfg_t;
  localparam cfg_t D = '{A: 5, B: `XW};
endpackage
module top #(parameter p::cfg_t C = p::D) (output logic [C.A-1:0] o);
  assign o = '0;
endmodule
