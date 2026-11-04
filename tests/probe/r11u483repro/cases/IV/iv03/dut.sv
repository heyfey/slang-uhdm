// § ifaceInstValueImplicitNet483
interface ifc (input logic clk); logic a; endinterface
module top; logic clk; ifc u(clk);
  function automatic void f(virtual ifc x); endfunction
  initial f(u);
endmodule
