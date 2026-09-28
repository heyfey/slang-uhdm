// § svModeAllFiles188 (Verilog-mode .v cells, run with drivers/case.sh TOP=dut.v)
interface ifc (input wire clk);
  logic        reset;
endinterface
module top();
wire clk;
ifc u(clk);
endmodule
