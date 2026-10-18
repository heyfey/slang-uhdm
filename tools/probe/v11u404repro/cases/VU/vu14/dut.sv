// § undefaultedDefInvalidInst404
module dut #(parameter p) (input a, output [3:0] y);
  for (genvar i = 0; i < 2**(p*3); i++) begin : g
    wire w = a;
  end
  assign y = '0;
endmodule
module top; endmodule
