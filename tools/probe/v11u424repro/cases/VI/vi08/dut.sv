// § ifcConcAssertListed424
interface ifc(input bit clk, input logic a);
  default clocking cb @(posedge clk); endclocking
  assert property (a);
endinterface
module top; bit c; logic x; ifc u(c, x); endmodule
