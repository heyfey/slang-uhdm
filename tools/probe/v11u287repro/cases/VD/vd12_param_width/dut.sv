// § defGenSelRefChainName287
module m #(parameter int W = 4) (input logic [31:0] rd [5], input logic [4:0] o, output logic [W-1:0] y [4]);
  for (genvar i = 0; i < 4; i++) begin : g
    assign y[i] = rd[i][o +: W];
  end
endmodule
