// § genCaCastRhsRefUnnamed198
module top (input logic [3:0] b, input logic [2:0] q [2], output logic [2:0] y [2][2]);
  for (genvar i = 0; i < 2; i++) begin : g
    for (genvar j = 0; j < 2; j++) begin : h
      assign y[i][j] = 3'(q[j]);
    end
  end
endmodule
