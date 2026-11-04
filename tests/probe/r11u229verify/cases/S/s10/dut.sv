// § strLitPpEscIdShift224 (a declined literal (a comment opener in the body) then an accepted one on the same line)
module top(output string o, output string p, output int k);
  initial begin
    o = "a\nb` //c"; p = "a\nb` c"; k = 1;
  end
endmodule
