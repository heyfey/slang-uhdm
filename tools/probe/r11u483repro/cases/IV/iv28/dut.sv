// § ifaceInstValueImplicitNet483
interface ifc (input logic clk); logic a; endinterface
module top; logic clk; ifc u(clk); int x;
  function automatic int f(virtual ifc x); return 1; endfunction
  initial x = f(u);
endmodule
