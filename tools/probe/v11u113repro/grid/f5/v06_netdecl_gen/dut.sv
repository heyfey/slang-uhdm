package pk; parameter int unsigned P = 4; endpackage
module top import pk::*; (input logic [3:0] a [2], input logic [3:0] a3 [2][2], input logic k, output logic y, output logic [3:0] q [2]);
  for (genvar w = 0; w < 2; w++) begin : g
    wire t = ~a[w][P-1];
    assign q[w] = {3'b0, t};
  end
  assign y = 1'b0;
endmodule
