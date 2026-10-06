// § selChainElemShapeIsSyntactic147 (decode only, ground A: Rggen d #27671, a plain member, no select, on the left side inside a macro body; ExprEmit)
`define conn(FIF) \
  assign  FIF.read_data = x;
interface bif; logic [7:0] read_data; logic [7:0] value; endinterface
module m(bif bif_port); logic [7:0] x;
  `conn(bif_port)
endmodule
module top; bif b(); m u(.bif_port(b)); endmodule
