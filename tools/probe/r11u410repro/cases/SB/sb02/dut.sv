// § modStructMemberBitsTypeFold410
module m #(parameter W = 16);
  typedef enum logic [3:0] { A, B } e_t;
  typedef struct packed { logic [W-$bits(e_t)-1:0] u; e_t op; } s_t;
  s_t x;
endmodule
module top;
endmodule
