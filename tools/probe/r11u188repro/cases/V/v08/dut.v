// § svModeAllFiles188 (Verilog-mode .v cells, run with drivers/case.sh TOP=dut.v)
interface ifc;
  logic        reset;
  modport  tb (output reset);
endinterface
module top();
ifc u();
endmodule
