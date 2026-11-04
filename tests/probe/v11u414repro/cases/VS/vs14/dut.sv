// § structMemberDefault414
module top;
  typedef struct { logic [3:0] a = 4'b1x0z; int b = 0; } s_t;
  s_t s;
endmodule
