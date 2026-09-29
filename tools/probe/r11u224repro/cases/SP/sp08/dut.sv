// § strLitPpEscIdShift224
module top(input string s, output string o);
  always_comb begin
    o = {"a\nb` c", s};
  end
endmodule
