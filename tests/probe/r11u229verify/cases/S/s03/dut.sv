// § strLitPpEscIdShift224 (a tab then a blank after the escape: neither alternative ends on the tab)
module top(output string o, output int k);
  initial begin
    o = "a\b	 c` d"; k = 1;
  end
endmodule
