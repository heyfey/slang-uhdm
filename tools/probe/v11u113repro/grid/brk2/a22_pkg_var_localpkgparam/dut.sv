package pk; localparam int unsigned P = 5; logic [P:0] pv; endpackage
module top import pk::*; (input logic [7:0] i, output logic [7:0] o);
  assign pv = i[5:0];
  assign o = pv;
endmodule
