// § defGenSelRefChainName287
module m #(parameter int W = 16) (input logic [31:0] rd [5], input logic [4:0] o, output logic [3:0] y [4]);
  for (genvar i = 0; i < 4; i++) begin : g
    assign y[i] = rd[i][o + $clog2(W) -: 4];
  end
endmodule
