// § hcSelIdxInstName168 § genCaFoldTsChainNamed169
module mod(input logic a);
endmodule
module dut #(parameter int P = 5) (input logic [7:0] v, input logic [2:0] s [2], output logic [7:0] o [2]);
  for (genvar c = 0; c < 2; c++) begin : g
    mod m(.a(v[s[c]]));
    mod n(.a(v[P % 4]));
    assign o[c] = v & P;
  end
endmodule
