// § modStructMemberBitsTypeFold410
package p;
  typedef enum logic [3:0] { A, B } e_t;
endpackage
`define DECL(w) typedef struct packed { logic [w-$bits(e_t)-1:0] u; e_t op; } s_t
module m import p::*; #(parameter W = 16);
  `DECL(W);
  s_t x;
endmodule
module top;
endmodule
