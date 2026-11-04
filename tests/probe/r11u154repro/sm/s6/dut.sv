// § builtinMethodArgNamedByPath154
module top;
   string s = "abcd";
   string t = "ab";
   int b;
   int c;
   assign b = s.compare(t);
   assign c = s.icompare(t);
endmodule
