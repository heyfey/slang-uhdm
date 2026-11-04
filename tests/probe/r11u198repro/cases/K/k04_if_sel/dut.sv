// § genCaCastRhsRefUnnamed198
module top #(parameter type T = logic [2:0], parameter int N = 2) (input logic s, input logic [2:0] q [2], input logic [3:0] b, output logic [2:0] y [2], output logic [2:0] z, output logic [3:0] y4, output logic [2:0] yt [2]);
  typedef logic [2:0] t3;
  if (N > 1) begin : g
    assign y[0] = 3'(s);
  end
endmodule
