// § undefaultedDefInvalidInst404
module dut #(parameter p, parameter q = p + 1) (input [q-1:0] a, output [p-1:0] y);
  assign y = a[p-1:0];
endmodule
module wrap; if (0) begin : abstract dut not_used(); end endmodule
module top; endmodule
