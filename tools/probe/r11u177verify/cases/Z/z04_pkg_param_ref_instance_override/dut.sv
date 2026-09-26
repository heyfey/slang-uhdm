// § ppOutputFile166 § aggFoldReanchorFile177v
`include "defs.svh"
package p;
  localparam int D = 5 + `XW;
endpackage
module sub #(parameter int C = 1) (output logic [C-1:0] o);
  assign o = '0;
endmodule
module top (output logic [68:0] o);
  sub #(.C(p::D)) u (.o(o));
endmodule
