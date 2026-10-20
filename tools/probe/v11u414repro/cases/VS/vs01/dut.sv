// § structMemberDefault414
typedef struct { int a = 3; bit [3:0] b; } s_t;
module top;
  s_t s;
endmodule
