// § ifcConcAssertListed424
interface ifc(input bit clk, input logic a);
  assert property (@(posedge clk) a);
endinterface
module mid(input bit c, input logic a); ifc u(c, a); endmodule
module top; bit c; logic x, y; mid m1(c, x); mid m2(c, y); endmodule
