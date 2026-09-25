// § builtinMethodArgNamedByPath154
module top;
   string s = "abcd";
   string t = "ab";
   int n;
   int b;
   initial begin : blk
     b = s.compare(t) + s.len();
     n = s.substr(1, b).len();
   end
endmodule
