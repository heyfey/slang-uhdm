package pk; parameter int unsigned P = 5; endpackage
module top import pk::*; (input logic [P:0] i [2], output logic [5:0] o);
  assign o = i[1];
endmodule
