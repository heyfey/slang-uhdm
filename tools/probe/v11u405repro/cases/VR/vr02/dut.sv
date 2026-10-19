// § nestedRepPatCount64_405
module top(output int o);
  typedef struct { int x[2]; int y; } s_t;
  s_t v = '{x: '{2{5}}, y: 3};
  assign o = v.y;
endmodule
