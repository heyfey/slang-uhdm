// § macroPathTokSpans183 (a generate loop in the macro, bit select of the member)
`define TIE(RIF, N) \
  for (genvar j = 0; j < N; ++j) begin : gt \
    assign RIF.bits[j] = 1'b1; \
  end
interface bif;
  logic [7:0] bits;
endinterface
module m(bif port_if);
  `TIE(port_if, 8)
endmodule
module top;
  bif b();
  m u(.port_if(b));
endmodule
