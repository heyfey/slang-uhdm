// § strLitPpEscIdShift224
module top(output string o);
  initial begin
    o = "a\nb` "; o = {o, "z"};
  end
endmodule
