// § genCaFoldTsChainNamed169
module dut (input logic [31:0] a [2], output logic [31:0] o [2]);
  child #(.P(3)) u (.a(a), .o(o));
endmodule
module child #(parameter int P = 6) (input logic [31:0] a [2], output logic [31:0] o [2]);
  for (genvar c = 0; c < 2; c++) begin : g
    assign o[c] = (a[c] ^ P) & a[c][P];
  end
endmodule
