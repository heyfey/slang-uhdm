// § undefaultedDefInvalidInst404
module dut #(parameter w) (input [w-1:0] a, output [2*w-1:0] y);
  localparam lw = w * 2;
  logic [lw-1:0] r;
  assign r = {a, a};
  assign y = r;
endmodule
module top; endmodule
