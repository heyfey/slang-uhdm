// § ifcConcAssertListed424
interface inner(input bit clk, input logic a);
  assert property (@(posedge clk) a);
endinterface
interface outer(input bit clk, input logic a);
  inner i0(clk, a);
endinterface
module top; bit c; logic x; outer o(c, x); endmodule
