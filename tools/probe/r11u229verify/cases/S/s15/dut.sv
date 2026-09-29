// § strLitPpEscIdShift224 (CRLF line ends, a statement after the literal)
module top(output string o, output int k);
  initial begin
    o = "a\nb` c"; k = 1;
  end
endmodule
