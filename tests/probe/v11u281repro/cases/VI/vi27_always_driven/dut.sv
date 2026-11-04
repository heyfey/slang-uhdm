// § ifaceTpUseBindsDefDefault281
interface ifc #(parameter type T = logic [3:0]);
  T d;
  logic clk;
endinterface
module dut(input logic clk, input logic [3:0] i, output logic [3:0] o);
  ifc u();
  assign u.clk = clk;
  always_ff @(posedge u.clk) u.d <= i;
  assign o = u.d;
endmodule
