// § ppOutputFile166 § aggFoldReanchorFile177v
`include "defs.svh"
package p;
  localparam int D = 5 + `XW;
endpackage
module top #(parameter int C = p::D) (output logic [C-1:0] o);
  assign o = '0;
endmodule
