// § selChainElemShapeIsSyntactic147 (decode only, ground A: Rggen d #27671, an interface member indexed part-select on a continuous assignment's left side; ExprEmit)
interface bif; logic [7:0] read_data; logic [7:0] value; endinterface
module top; bif b(); logic [3:0] x;
  assign b.read_data[0+:4] = x;
endmodule
