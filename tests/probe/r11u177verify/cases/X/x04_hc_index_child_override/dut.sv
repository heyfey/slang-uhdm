// § hcSelIdxInstName168 § genCaFoldTsChainNamed169
module mod(input logic a);
endmodule
module child #(parameter int P = 5) (input logic [7:0] v, input logic [2:0] i, output logic [7:0] o [2]);
  for (genvar c = 0; c < 2; c++) begin : g
    mod m(.a(v[i]));
    assign o[c] = v[P] ? v : P;
  end
endmodule
module dut (input logic [7:0] v, input logic [2:0] i, output logic [7:0] o [2]);
  child #(.P(3)) u(.v(v), .i(i), .o(o));
endmodule
