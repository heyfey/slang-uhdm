package pk; parameter int unsigned P = 4; endpackage
module top import pk::*; (input logic [3:0] a [2], output logic [1:0][3:0] q);
  for (genvar w = 0; w < 2; w++) begin : g
    assign q[w][P-1] = a[w][0];
    assign q[w][P-2:0] = '0;
  end
endmodule
