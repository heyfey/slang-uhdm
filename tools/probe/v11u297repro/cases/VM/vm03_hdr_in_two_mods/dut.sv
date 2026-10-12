// § varDeclInitMovesSharedTsEnd297
typedef struct packed { logic [1:0] a; logic b; } t_t;
module m1(output logic [2:0] o);
`include "decl.svh"
  assign o = x;
endmodule
module m2(output logic [2:0] o);
  `include "decl.svh"
  assign o = x;
endmodule
module dut(output logic [2:0] o, q);
  m1 u1(.o(o));
  m2 u2(.o(q));
endmodule
