module m(input logic [31:0] rd [4], output logic [7:0] y [4]);
  for (genvar i = 0; i < 4; i++) begin : g
    assign y[i] = rd[i][i*8 +: 8];
  end
endmodule
