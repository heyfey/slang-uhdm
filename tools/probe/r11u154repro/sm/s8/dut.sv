// § builtinMethodArgNamedByPath154
module top;
   string s = "abcd";
   string t = "ab";
   int b;
   initial begin : blk
     b = s.compare(t);
   end
endmodule
