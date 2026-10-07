// § ifacePortViewNoProcs283
interface ifc (input logic clk);
  logic [3:0] d;
  always @(posedge clk) d <= d + 1;
endinterface
program prg (ifc m); int f; initial f = m.d; endprogram
module dut (input logic clk, output logic [3:0] o);
  ifc a (.clk(clk));
  prg p (.m(a));
  assign o = a.d;
endmodule
