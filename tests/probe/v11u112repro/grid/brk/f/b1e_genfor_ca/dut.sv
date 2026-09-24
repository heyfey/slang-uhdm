package pk; parameter int unsigned P = 2; endpackage
module top import pk::*; (input logic [7:0] a, output logic [3:0] y);
  for (genvar i = 0; i < 4; i++) begin : g
    assign y[i] = a[P-1+i];
  end
endmodule
