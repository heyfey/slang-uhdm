// § strLitPpEscIdShift224
module top(output string o);
  string s = "a\nb` c";
  assign o = s;
endmodule
