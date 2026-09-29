// § strLitPpEscIdShift224
module top(output string o, output string p);
  initial begin
    o = "a\nb` c"; p = "d \
e";
  end
endmodule
