// § defGenSelRefChainName287
module m(input logic [31:0] rd [5], input logic [4:0] o, output logic [7:0] y [4]);
  for (genvar i = 0; i < 4; i++) begin : g
    assign y[i] = {rd[i][o -: 4], rd[i+1][o +: 4]};
  end
endmodule
