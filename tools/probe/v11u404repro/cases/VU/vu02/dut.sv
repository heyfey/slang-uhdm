// § undefaultedDefInvalidInst404
module dut #(parameter string s) (input a, output y);
  assign y = a;
  initial $display(s);
endmodule
module top; endmodule
