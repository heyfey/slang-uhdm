// § genHopFoldSelName198
module top #(parameter int N = 2) (input logic [15:0] a, input logic s, output logic [3:0] y, output logic [15:0] y16, output logic [1:0] y2 [4]);
  for (genvar i = 0; i < 4; i++) begin : g
    localparam int unsigned L = i*2;
    if (N > 1) begin : h
      assign y16[L] = a[i];
      assign y16[L+1] = s;
    end
  end
endmodule
