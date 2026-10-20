// § implicitPortPaLastIface419
interface ifc #(parameter A = 4, parameter B = 2) (input clk);
  logic [A-1:0] x;
  modport mp(input clk, x);
endinterface
module dut(ifc.mp p);
endmodule
module top;
  logic clk;
  for (genvar g = 0; g < 2; g++) begin : gg
    ifc #(.B(g)) u(clk);
    dut d(u);
  end
endmodule
