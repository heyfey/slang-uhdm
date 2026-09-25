// § varInitStrMethodArgDefNet154
module m #(parameter int K = 1);
   string s = "abcd";
   string t = "ab";
   int  b = s.compare(t) + K;
endmodule
module top; m #(1) u1(); m #(2) u2(); endmodule
