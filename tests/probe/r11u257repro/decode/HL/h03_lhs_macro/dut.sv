// § selChainElemShapeIsSyntactic147 (decode only, ground A: Rggen d #27671, inside a macro body; ExprEmit)
`define conn(FIF, LSB, WIDTH) \
  assign  FIF.read_data[LSB+:WIDTH] = x;
interface bif; logic [7:0] read_data; logic [7:0] value; endinterface
module m(bif bit_field_if); logic [3:0] x;
  `conn(bit_field_if, 0, 4)
endmodule
module top; bif b(); m u(.bit_field_if(b)); endmodule
