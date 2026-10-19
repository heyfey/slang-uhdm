// § timeModVarIsNet406
module child;
  time t;
  always #1 t = t + 1;
endmodule
module top;
  child c1();
  child c2();
endmodule
