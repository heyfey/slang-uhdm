// § builtinMethodArgNamedByPath154
module top;
   string s = "abcd";
   int i = 0;
   byte c;
   always_comb c = s.getc(i);
   initial s.putc(i, "z");
endmodule
