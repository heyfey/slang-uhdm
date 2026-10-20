// § structMemberDefault414
module top;
  typedef struct packed { logic [3:0] a; } p_t;
  typedef struct { p_t p; int b = 'h10; } s_t;
  s_t s;
endmodule
