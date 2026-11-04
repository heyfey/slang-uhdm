// § strLitPpEscIdShift224 (three backslashes in one escaped identifier: +4 where +2-per-backslash reads +6)
module top(output string o, output int k);
  initial begin
    o = "a\n\t\v q` r"; k = 1;
  end
endmodule
