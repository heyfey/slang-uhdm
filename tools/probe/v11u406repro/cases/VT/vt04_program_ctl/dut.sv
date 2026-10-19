// § timeModVarIsNet406
program p;
  time t;
  initial t = $time;
endprogram
module top;
  p u();
endmodule
