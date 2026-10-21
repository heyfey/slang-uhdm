// § ifcConcAssertListed424
interface ifc(input bit clk, input logic a);
  assert property (@(posedge clk) a);
endinterface
module top; bit c; logic [1:0] x; ifc u[1:0] (c, x); endmodule
