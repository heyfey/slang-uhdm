// § genCaFoldTsChainNamed169
module leaf #(parameter int P = 6) (input logic [31:0] i, output logic [31:0] z);
  logic [31:0] o [2];
  for (genvar c = 0; c < 2; c++) begin : g
    assign o[c] = i & P;
    assign o[c] = P;
  end
  assign z = o[0];
endmodule
module dut (input logic [31:0] i, output logic [31:0] z);
  leaf #(.P(9)) u (.i(i), .z(z));
endmodule
