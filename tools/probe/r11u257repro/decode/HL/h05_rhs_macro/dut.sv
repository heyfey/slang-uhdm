// § selChainElemShapeIsSyntactic147 (decode only, ground A: Rggen d #27671, the same select on the right side inside a macro body; ExprEmit)
`define conn(FIF, LSB, WIDTH) \
  assign  x = FIF.read_data[LSB+:WIDTH];
interface bif; logic [7:0] read_data; logic [7:0] value; endinterface
module m(bif bit_field_if); logic [3:0] x;
  `conn(bit_field_if, 0, 4)
endmodule
module top; bif b(); m u(.bit_field_if(b)); endmodule
