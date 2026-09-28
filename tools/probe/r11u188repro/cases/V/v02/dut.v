// § svModeAllFiles188 (Verilog-mode .v cells, run with drivers/case.sh TOP=dut.v)
interface ifc (input wire clk);
  logic        reset;
  logic  [7:0] d;
  modport  tb (input clk, output reset, input d);
endinterface
module top();
wire clk;
ifc u(clk);
endmodule
