// § macroIfacePathTokSpans183 (a part select lvalue and a variable index)
`define tie(RIF, K) \
    always_comb begin RIF.read_data[1:0] = 2'b0; RIF.read_data[K] = 1'b1; end
interface bif;
  logic [3:0] read_data;
endinterface
module m(bif bit_field_if, input int k);
  `tie(bit_field_if, k)
endmodule
module top(input int k);
  bif b();
  m u(.bit_field_if(b), .k(k));
endmodule
