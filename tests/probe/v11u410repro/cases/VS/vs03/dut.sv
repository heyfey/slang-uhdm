// § modStructMemberBitsTypeFold410
module top #(parameter P = 4);
  localparam Q = 3;
  typedef struct packed {
    logic [$bits(Q)-1:0] a;
    logic [P-1:0] b;
  } s_t;
  s_t v;
endmodule
