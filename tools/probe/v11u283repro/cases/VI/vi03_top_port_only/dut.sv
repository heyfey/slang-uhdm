// § ifacePortViewNoProcs283
interface ifc (input logic clk);
  logic [3:0] d;
  always @(posedge clk) d <= d + 1;
  modport mp (input d);
endinterface
module dut (ifc.mp m, output logic [3:0] o);
  assign o = m.d;
endmodule
