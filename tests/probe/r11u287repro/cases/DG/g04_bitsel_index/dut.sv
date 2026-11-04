// § defGenSelRefChainName287
module m (input logic [7:0] a [4], input logic [1:0] k, output logic [7:0] y [2]);
  for (genvar i = 0; i < 2; i++) begin : g
    assign y[i] = a[k + i];
  end
endmodule
