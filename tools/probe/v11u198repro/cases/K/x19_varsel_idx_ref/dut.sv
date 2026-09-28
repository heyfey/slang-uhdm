// § genCaCastRhsRefUnnamed198
module top (input logic [1:0] k, input logic [3:0] m [4][4], output logic [2:0] y [2]);
  for (genvar i = 0; i < 2; i++) begin : g
    assign y[i] = 3'(m[k][i]);
  end
endmodule
