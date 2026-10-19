// § modStructMemberBitsTypeFold410
module top;
  typedef logic [4:0] w_t;
  typedef struct packed { logic [3:0] a; w_t b; } in_t;
  typedef struct packed {
    logic [$bits(in_t)-1:0] raw;
    logic v;
  } s_t;
  s_t v;
endmodule
