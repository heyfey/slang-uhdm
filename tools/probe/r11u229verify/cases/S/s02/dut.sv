// § strLitPpEscIdShift224 (an escape at the end of the body with no blank after it: no escaped identifier)
module top(output string o, output int k);
  initial begin
    o = "a` \b"; k = 1;
  end
endmodule
