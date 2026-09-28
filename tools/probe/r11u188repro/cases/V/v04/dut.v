// § svModeAllFiles188 (Verilog-mode .v cells, run with drivers/case.sh TOP=dut.v)
module m(input a);
  logic        q;
  assign q = a;
endmodule
module top();
logic a;
m u(a);
endmodule
