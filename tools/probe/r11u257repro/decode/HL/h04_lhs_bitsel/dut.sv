// § selChainElemShapeIsSyntactic147 (decode only, ground A: Rggen d #27671, a bit select and a part select on the left side; ExprEmit)
interface bif; logic [7:0] read_data; logic [7:0] value; endinterface
module m(bif bit_field_if); logic x;
  assign bit_field_if.read_data[1] = x;
  assign bit_field_if.value[3:0] = {4{x}};
endmodule
module top; bif b(); m u(.bit_field_if(b)); endmodule
