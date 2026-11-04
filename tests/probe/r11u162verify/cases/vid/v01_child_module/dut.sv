// § varInitStrMethodArgDefNet154
module ch;
  string s = "abcd";
  string t = "ab";
  int b = s.icompare(t);
endmodule
module top; ch c1(); ch c2(); endmodule
