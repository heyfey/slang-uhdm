// § varInitStrMethodArgDefNet154
module m;
   string s = "abcd";
   string t = "ab";
   int  b = s.compare(t);
endmodule
module top; m u1(); m u2(); endmodule
