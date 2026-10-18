// § undefaultedDefInvalidInst404
module dut #(parameter p) (input a, output y);
  int arr [p-8];
  assign y = a;
endmodule
module top; endmodule
