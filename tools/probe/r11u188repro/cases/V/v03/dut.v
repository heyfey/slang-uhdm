// § svModeAllFiles188 (Verilog-mode .v cells, run with drivers/case.sh TOP=dut.v)
interface ifc;
  logic a, b;
  logic c = 1'b0, e;
endinterface
module top();
ifc u();
endmodule
