// § modStructMemberBitsTypeFold410
interface ifc;
  typedef enum logic [1:0] {X, Y} e_t;
  typedef struct packed { logic [$bits(e_t)-1:0] k; } s_t;
  s_t v;
endinterface
module top;
  ifc u();
endmodule
