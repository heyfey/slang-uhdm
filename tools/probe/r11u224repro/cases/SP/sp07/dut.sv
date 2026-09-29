// § strLitPpEscIdShift224
module top(output string o, output string p);
  initial begin
    o = "a\nb` c"; p = "x\ty` z";
  end
endmodule
