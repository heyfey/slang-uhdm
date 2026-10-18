// § undefaultedDefInvalidInst404
module dut #(parameter p) (input a, output y);
  if (p > 1) begin : r
    dut #(.p(p - 1)) u (.a(a), .y(y));
  end else begin : b
    assign y = a;
  end
endmodule
module top; endmodule
