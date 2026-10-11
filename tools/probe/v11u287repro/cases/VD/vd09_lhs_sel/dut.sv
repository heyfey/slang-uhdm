// § defGenSelRefChainName287
module m(input logic [3:0] a [4], input logic [4:0] o, output logic [31:0] y [4]);
  for (genvar i = 0; i < 4; i++) begin : g
    always_comb begin y[i] = '0; y[i][o -: 4] = a[i]; end
  end
endmodule
