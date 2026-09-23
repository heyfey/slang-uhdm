package pk; parameter int unsigned P = 5; endpackage
module top import pk::*; (input logic [7:0] i, output logic [7:0] o);
  localparam logic [P:0] L = '1;
  assign o = L;
endmodule
