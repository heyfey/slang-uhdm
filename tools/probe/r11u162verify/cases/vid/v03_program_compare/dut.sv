// § varInitDefNetModuleOnly154v
program prg;
  string s = "abcd";
  string t = "ab";
  int b = s.compare(t);
endprogram
module top; prg p(); endmodule
