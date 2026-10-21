// § ifcConcAssertListed424
string label = "L";
interface ifc(input bit clk, input logic a);
  assert property (@(posedge clk) a) else $error("%s", label);
  cover sequence (@(posedge clk) a ##1 !a);
endinterface
module top; bit c; logic x, y; ifc u1(c, x); ifc u2(c, y); endmodule
