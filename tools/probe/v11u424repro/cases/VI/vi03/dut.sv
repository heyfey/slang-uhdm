// § ifcConcAssertListed424
interface ifc(input bit clk, input logic a, input logic b);
  cover property (@(posedge clk) a ##1 b);
  assume property (@(posedge clk) a |=> b);
endinterface
module top; bit c; logic x, y; ifc u(c, x, y); endmodule
