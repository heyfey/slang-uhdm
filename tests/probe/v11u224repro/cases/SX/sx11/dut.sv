// § strLitPpEscIdShift224
module top(output string o, output int k);
  `define M(x) o = x;
  initial begin
    `M("a\nb` c") k = 1;
  end
endmodule
