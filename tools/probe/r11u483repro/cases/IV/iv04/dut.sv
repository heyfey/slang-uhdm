// § ifaceInstValueImplicitNet483
interface ifc (input logic clk); logic a; endinterface
class C; virtual ifc v; function void set(virtual ifc x); v = x; endfunction endclass
module top; logic clk; ifc u(clk);
  initial begin C c; c = new; c.set(u); end
endmodule
