// § varInitDefNetModuleOnly154v
program pg;
   string s = "abcd";
   string t = "ab";
   int  b = s.compare(t);
endprogram
module top; pg p(); endmodule
