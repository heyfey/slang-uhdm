module m(input logic [15:0] rd [2][3], input logic [3:0] o, output logic [3:0] y [2][3]);
  for (genvar i = 0; i < 2; i++) begin : g
    for (genvar j = 0; j < 3; j++) begin : h
      assign y[i][j] = rd[i][j][o -: 4];
    end
  end
endmodule
