// § timeModVarIsNet406
module child(output time o);
  assign o = 64'd9;
endmodule
module top;
  time t;
  child c(.o(t));
endmodule
