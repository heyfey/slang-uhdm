// § ifaceInstValueImplicitNet483
interface ifc (input logic clk); logic a; endinterface
module top; logic clk; ifc u(clk);
  initial begin virtual ifc q[$]; q.push_back(u); end
endmodule
