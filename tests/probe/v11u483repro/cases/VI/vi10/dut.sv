// § ifaceInstValueImplicitNet483
interface ifc (input logic clk); logic a; endinterface
module top; logic clk; ifc u(clk); virtual ifc g;
  function automatic virtual ifc rf(); return u; endfunction
  initial g = rf();
endmodule
