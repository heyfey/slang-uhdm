// § varInitStrMethodArgDefNet154
module m(input string t);
  string s = "abcd";
  int b = s.compare(t);
endmodule
module top; string x = "ab"; m u(x); endmodule
