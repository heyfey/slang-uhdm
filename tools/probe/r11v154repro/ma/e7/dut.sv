// § builtinMethodArgNamedByPath154
module top;
   string s = "abcd";
   string t = "ab";
   int b;
   function automatic int f(); return s.compare(t); endfunction
   assign b = f();
endmodule
