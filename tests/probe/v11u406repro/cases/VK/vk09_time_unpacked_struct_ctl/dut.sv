// § timeModVarIsNet406
module top;
  typedef struct { time a; int b; } s_t;
  s_t v;
  time t;
  initial v.a = t;
endmodule
