// § ifcConcAssertListed424
interface ifc(input bit clk, input logic a, input logic b);
  property p; @(posedge clk) a |-> ##1 b; endproperty
  ap: assert property (p);
endinterface
module top; bit c; logic x, y; ifc u(c, x, y); endmodule
