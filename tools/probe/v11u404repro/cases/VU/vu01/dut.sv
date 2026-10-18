// § undefaultedDefInvalidInst404
module dut #(parameter p) (input [p-1:0] a, output y);
  if (p > 4) begin : g1
    assign y = a[0];
  end else begin : g2
    assign y = 1'b0;
  end
endmodule
module top; endmodule
