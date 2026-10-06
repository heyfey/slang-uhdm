// § selChainElemShapeIsSyntactic147 (decode only, ground A: Rggen d #27671, the same through an interface port; ExprEmit)
interface bif; logic [7:0] read_data; logic [7:0] value; endinterface
module m(bif bit_field_if); logic [3:0] x;
  assign bit_field_if.read_data[0+:4] = x;
endmodule
module top; bif b(); m u(.bit_field_if(b)); endmodule
