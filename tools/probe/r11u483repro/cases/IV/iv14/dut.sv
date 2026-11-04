// § ifaceInstValueImplicitNet483
interface ifc (input logic clk); logic a; endinterface
class C; virtual ifc v; function new(virtual ifc x); v = x; endfunction endclass
module top; logic clk; ifc u(clk);
  C c;
  initial c = new(u);
endmodule
