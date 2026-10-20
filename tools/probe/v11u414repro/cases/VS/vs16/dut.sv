// § structMemberDefault414
module sub;
  typedef struct { int a = 3; } s_t;
  s_t s;
endmodule
module top;
  sub u1();
  sub u2();
endmodule
