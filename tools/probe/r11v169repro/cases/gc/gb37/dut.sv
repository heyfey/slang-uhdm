// § genCaFoldTsChainNamed169
module dut #(parameter int P = 6, parameter logic [3:0] Q = 4'd2) (input logic [31:0] a [2], output logic [31:0] o [2]);
  for (genvar c = 0; c < 2; c++) begin : g
    assign o[c] = (a[c] & P) | Q;
  end
endmodule
