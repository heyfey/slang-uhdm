// § implicitPortPaLastIface419
interface ifc #(parameter A = 4, int B = 2) (input clk);
  logic [A-1:0] x;
  modport mp(input clk, x);
endinterface
module dut(ifc.mp p);
endmodule
module top;
  logic clk;
  ifc #(.B(3)) u(clk);
  dut d(u);
endmodule
