// § nestedDefPortsNeedShell297
interface ifc(input logic clk);
  logic d;
  modport m(input clk, output d);
endinterface
module dut(input logic clk, output logic o);
  ifc i(.clk(clk));
  assign i.d = 1'b1;
  assign o = i.d;
endmodule
