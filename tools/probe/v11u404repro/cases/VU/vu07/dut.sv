// § undefaultedDefInvalidInst404
module dut #(parameter real r, parameter int n) (output real y, output int z);
  assign y = r * 2.0;
  assign z = n + 1;
endmodule
module top; endmodule
