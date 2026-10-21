// § ifcConcAssertListed424
interface ifc(input bit clk, input logic a);
  assert property (@(posedge clk) a);
endinterface
module top; bit c; logic x;
  ifc u(c, x);
  assert property (@(posedge c) x);
endmodule
