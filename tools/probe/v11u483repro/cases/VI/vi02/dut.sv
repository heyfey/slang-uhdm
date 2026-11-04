// § ifaceInstValueImplicitNet483
interface ifc (input logic clk); logic a; endinterface
module top; logic clk; ifc u(clk); virtual ifc g;
  function int f(virtual ifc x); g = x; return 1; endfunction
  initial void'(f(u));
endmodule
