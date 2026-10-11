// § defGenSelRefChainName287
`define SEL(a, b) a[b -: 4]
module m(input logic [31:0] rd [5], input logic [4:0] o, output logic [3:0] y [4]);
  for (genvar i = 0; i < 4; i++) begin : g
    assign y[i] = `SEL(rd[i], o);
  end
endmodule
