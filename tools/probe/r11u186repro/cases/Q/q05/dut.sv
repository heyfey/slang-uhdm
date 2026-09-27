// § macroPathTokOneBuffer186 (a genvar select in the macro body beside an argument select)
`define TIE2(RIF, LSB) \
  for (genvar k = 0; k < 2; ++k) begin : gt \
    assign RIF.bits[k] = RIF.bits[LSB]; \
  end
interface bif;
  logic [7:0] bits;
endinterface
module m(bif port_if);
  `TIE2(port_if, 5)
endmodule
module top;
  bif b();
  m u(.port_if(b));
endmodule
