// § ifaceInstValueImplicitNet483
interface ifc (input logic clk); logic a; endinterface
module top; logic clk; ifc u(clk); virtual ifc q[$];
  initial begin q.push_back(u); q.push_front(u); end
endmodule
