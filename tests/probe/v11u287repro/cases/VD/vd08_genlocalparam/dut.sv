// § defGenSelRefChainName287
module m(input logic [31:0] rd [8], input logic [4:0] o, output logic [3:0] y [4]);
  for (genvar i = 0; i < 4; i++) begin : g
    localparam int K = i * 2;
    assign y[i] = rd[K][o -: 4];
  end
endmodule
