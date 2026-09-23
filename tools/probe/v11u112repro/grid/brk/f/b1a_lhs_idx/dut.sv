package pk; parameter int unsigned P = 2; endpackage
module top import pk::*; (input logic a, output logic [3:0] y);
  assign y[P-1] = a;
  assign y[P+1] = ~a;
endmodule
