// § builtinMethodArgNamedByPath154
module top;
   string s = "abcd";
   string t = "ab";
   int b;
   generate if (1) begin : g
     always_comb b = s.icompare(t);
   end endgenerate
endmodule
