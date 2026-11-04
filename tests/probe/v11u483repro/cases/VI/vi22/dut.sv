// § ifaceInstValueImplicitNet483
interface ifc (input logic clk); logic a; endinterface
class D; virtual ifc v; function new(virtual ifc x); v = x; endfunction endclass
module top; logic clk; ifc u(clk); D d;
  always @(posedge clk) d = new(u);
  initial begin : b virtual ifc h; h = u; end
endmodule
