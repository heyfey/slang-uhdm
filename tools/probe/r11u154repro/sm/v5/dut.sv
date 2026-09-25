// § builtinMethodArgNamedByPath154
module top;
   string s = "abcd";
   string t = "ab";
   function automatic int f(); int b = s.compare(t); return b; endfunction
   int c;
   assign c = f();
endmodule
