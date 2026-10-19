// § modStructMemberBitsTypeFold410
module m #(parameter W = 16);
  typedef struct packed { logic [W-$bits(logic [3:0])-1:0] u; logic [$clog2(W)-1:0] v; } s_t;
  s_t x;
endmodule
module top;
endmodule
