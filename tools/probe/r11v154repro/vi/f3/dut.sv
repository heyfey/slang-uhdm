// § varInitStrMethodArgDefNet154
module top;
   string s = "abcd";
   generate if (1) begin : g
     string t = "ab";
     int  b = s.compare(t);
   end endgenerate
endmodule
