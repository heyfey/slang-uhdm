// § defGenSelRefChainName287
module m(input logic [31:0] rd [5], input logic [4:0] o [2], output logic [3:0] y [4]);
  for (genvar i = 0; i < 4; i++) begin : g
    assign y[i] = rd[i][o[1] -: 4];
  end
endmodule
