// § undefaultedDefInvalidInst404
module dut #(parameter p) (input [7:0] a, output [7:0] y);
  localparam x = 16 / (p - 8);
  logic [7:0] m [0:p-9];
  assign y = a >> x;
endmodule
module top; endmodule
