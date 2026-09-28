// § svModeAllFiles188 (Verilog-mode .v cells, run with drivers/case.sh TOP=dut.v)
program p(input wire clk);
  logic        r;
endprogram
module top();
logic clk = 0;
p u(clk);
endmodule
