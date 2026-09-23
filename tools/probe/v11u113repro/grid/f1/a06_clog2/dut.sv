package pk; parameter int unsigned P = $clog2(64); endpackage
module top import pk::*; (input logic [7:0] i, output logic [7:0] o);
  logic [P:0] x;
  assign x = i[6:0];
  assign o = x;
endmodule
