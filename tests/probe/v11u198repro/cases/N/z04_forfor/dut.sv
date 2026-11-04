// § genHopFoldSelName198
module top (input logic [15:0] a, output logic [3:0] y [2]);
  for (genvar i = 0; i < 2; i++) begin : g
    localparam int L = i*4;
    for (genvar j = 0; j < 4; j++) begin : h
      assign y[i][j] = a[L+j];
    end
  end
endmodule
