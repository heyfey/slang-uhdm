// § undefaultedDefInvalidInst404
module leaf #(parameter W = 1) (input [W-1:0] a, output [W-1:0] b); assign b = a; endmodule
module dut #(parameter p) (input [p-1:0] a, output [p-1:0] y);
  leaf #(.W(p)) u (.a(a), .b(y));
endmodule
module top; endmodule
