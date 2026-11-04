// § strLitPpEscIdShift224
module top(output string o);
  string t [2] = '{"a\nb` c", "d"};
  initial o = t[0];
endmodule
