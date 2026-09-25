// § builtinMethodArgNamedByPath154
module top;
  string s = "abcd";
  string t = "abxy";
  int b;
  assign b = s.compare(t.substr(0, 1));
endmodule
