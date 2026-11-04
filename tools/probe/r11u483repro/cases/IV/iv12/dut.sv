// § ifaceInstValueImplicitNet483
interface ifc (input logic clk); logic a; endinterface
module top; logic clk;
  for (genvar i = 0; i < 1; i++) begin : g
    ifc u(clk);
    virtual ifc mv;
    initial mv = u;
  end
endmodule
