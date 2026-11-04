// r11u220 decode (residue): a backtick-blank string literal shifts its end column by another rule
module top(output string o);
   initial begin
      o = "a\tb` c";
   end
endmodule
