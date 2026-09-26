// § ppOutputFile166 § aggFoldReanchorFile177v
`include "defs.svh"
module top (output logic [7:0] o);
  localparam int D = 5 + `XW; localparam int E = D;
  assign o = E[7:0];
endmodule
