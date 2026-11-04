// § kwArrayMethodIsCallElem401
module top;
  typedef struct { int a[3]; } s_t;
  s_t s; int y;
  initial y = s.a.xor;
endmodule
