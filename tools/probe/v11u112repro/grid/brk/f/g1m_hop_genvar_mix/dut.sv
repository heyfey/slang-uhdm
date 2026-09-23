module top (input logic [31:0] a, output logic [3:0] y [4]);
  for (genvar i = 0; i < 4; i++) begin : g
    localparam int unsigned L = i*4;
    for (genvar j = 0; j < 4; j++) begin : h
      assign y[i][j] = a[L+j];
    end
  end
endmodule
