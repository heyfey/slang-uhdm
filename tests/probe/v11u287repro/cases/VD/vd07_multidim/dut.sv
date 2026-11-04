// § defGenSelRefChainName287
module m(input logic [31:0] rd [5][2], input logic [4:0] o, input logic j, output logic [3:0] y [4]);
  for (genvar i = 0; i < 4; i++) begin : g
    assign y[i] = rd[i][j][o -: 4];
  end
endmodule
