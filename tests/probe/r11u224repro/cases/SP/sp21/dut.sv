// § strLitPpEscIdShift224
module top(output string o, output int k);
  initial begin
    o = "a\nb` c"; k = 5;
  end
endmodule
