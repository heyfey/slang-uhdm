// § selChainElemShapeIsSyntactic147 (decode only, ground A: Rggen d #27671, a bit select on the left side inside a macro body, a short actual; ExprEmit)
`define conn(FIF, LSB) \
  assign  FIF.read_data[LSB] = x;
interface bif; logic [7:0] read_data; logic [7:0] value; endinterface
module m(bif bi); logic x;
  `conn(bi, 2)
endmodule
module top; bif b(); m u(.bi(b)); endmodule
