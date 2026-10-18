// § undefaultedDefInvalidInst404
module dut #(parameter p) (input a, output y);
  if (p == 8) begin : g
    $error("placeholder width %0d", p);
  end
  assign y = a;
endmodule
module top; endmodule
