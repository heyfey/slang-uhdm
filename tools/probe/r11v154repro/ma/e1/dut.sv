// § builtinMethodArgNamedByPath154
module top;
   string s = "abcd";
   string t = "ab";
   int b;
   initial begin
     b = s.compare(t.substr(0, 1));
   end
endmodule
