// § genHopFoldSelName198
module top #(parameter int N = 2, parameter int unsigned P = 3) (input logic [15:0] a, input logic s, input logic [3:0] m [8], input logic [31:0] w, output logic [3:0] y, output logic [1:0] y2 [4], output logic [7:0] z);
  for (genvar i = 0; i < 4; i++) begin : g
    localparam int unsigned L = i*2;
    if (N > 1) begin : h
      assign y2[i] = {s, a[L]};
    end
  end
endmodule
