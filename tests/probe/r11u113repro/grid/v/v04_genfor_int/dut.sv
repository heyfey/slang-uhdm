package pk; parameter int unsigned P = 4; parameter int S = 4; parameter U = 4; endpackage
module top import pk::*; (input logic [3:0] a [2], input logic k, output logic y, output logic z [2]);
  for (genvar w = 0; w < 2; w++) begin : g
    assign z[w] = ~a[w][S-1];
  end
  assign y = 1'b0;
endmodule
