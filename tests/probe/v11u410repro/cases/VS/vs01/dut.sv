// § modStructMemberBitsTypeFold410
module top;
  typedef enum logic [2:0] {A, B, C} e_t;
  typedef struct packed {
    logic [$bits(e_t)-1:0] f;
    logic [$bits(e_t)*2-1:0] g;
  } s_t;
  s_t v;
endmodule
