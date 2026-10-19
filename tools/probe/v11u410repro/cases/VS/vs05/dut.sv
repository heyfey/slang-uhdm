// § modStructMemberBitsTypeFold410
module top;
  typedef logic [6:0] w_t;
  typedef union packed {
    logic [$bits(w_t)-1:0] a;
    w_t b;
  } u_t;
  typedef struct packed { logic [$bits(w_t):0] c; } s_t;
  u_t v; s_t q;
endmodule
