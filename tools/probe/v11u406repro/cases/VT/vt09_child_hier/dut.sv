// § timeModVarIsNet406
module child;
  time t;
endmodule
module top;
  child c();
  initial c.t = 7;
endmodule
