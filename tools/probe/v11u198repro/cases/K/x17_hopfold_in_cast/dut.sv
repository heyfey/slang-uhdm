// § genCaCastRhsRefUnnamed198
module top #(parameter int N = 2) (input logic [15:0] a, output logic [2:0] y [4]);
  for (genvar i = 0; i < 4; i++) begin : g
    localparam int unsigned L = i*2;
    if (N > 1) begin : h
      assign y[i] = 3'(a[L]);
      assign y[i] = 3'(a[L+1]);
    end
  end
endmodule
