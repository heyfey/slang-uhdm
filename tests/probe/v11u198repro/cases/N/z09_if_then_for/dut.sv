// § genHopFoldSelName198
module top #(parameter int N = 2) (input logic [15:0] a, input logic s, output logic [3:0] y, output logic [15:0] y16, output logic [1:0] y2 [4]);
  if (N > 1) begin : g
    localparam int unsigned L = 3;
    for (genvar j = 0; j < 4; j++) begin : h
      assign y[j] = a[L] ^ a[L+j];
    end
  end
endmodule
