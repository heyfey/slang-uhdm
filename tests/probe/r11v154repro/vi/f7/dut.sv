// § varInitStrMethodArgDefNet154
module leaf;
   string s = "abcd";
   string t = "ab";
   int  b = s.compare(t);
endmodule
module mid; leaf l(); endmodule
module top; mid m(); endmodule
