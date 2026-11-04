// § strLitPpEscIdShift224 (a dollar in the escape run)
module top(output string o, output int k);
  initial begin
    o = "a\$x` c"; k = 2;
  end
endmodule
