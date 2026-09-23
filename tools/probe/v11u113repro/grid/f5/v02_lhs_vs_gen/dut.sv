package pk; parameter int unsigned P = 4; endpackage
module top import pk::*; (input logic [3:0] a [2], input logic [3:0] a3 [2][2], input logic k, output logic y, output logic [3:0] q [2]);
  for (genvar w = 0; w < 2; w++) begin : g
    assign q[w][P-1] = a[w][0];
  end
  assign y = 1'b0;
endmodule
