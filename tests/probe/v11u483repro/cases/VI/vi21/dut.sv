// § ifaceInstValueImplicitNet483
interface ifc (input logic clk); logic a; endinterface
module sub; logic clk; ifc u(clk); virtual ifc g;
  task automatic tk(); g = u; endtask
  initial tk();
endmodule
module top; sub s1(); sub s2(); endmodule
