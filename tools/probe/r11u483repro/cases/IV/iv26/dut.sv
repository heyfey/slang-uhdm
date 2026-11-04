// § ifaceInstValueImplicitNet483
interface ifc (input logic clk); logic a; endinterface
module top; logic clk; ifc u(clk);
  class C; virtual ifc v; function void f(); v = u; endfunction endclass
  initial begin C c; c = new; c.f(); end
endmodule
