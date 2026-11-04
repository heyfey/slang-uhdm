// § strLitPpEscIdShift224 (W inside the escape run after other letters: the second alternative reads it)
module top(output string o, output int k);
  initial begin
    o = "a\nyW z` q"; k = 1;
  end
endmodule
