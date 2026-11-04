// § ifacePortArrMemberChainPath401
typedef struct packed { logic [1:0] g; logic h; } in_t;
typedef struct packed { in_t f; logic k; } st_t;
module sub; st_t st [2]; endmodule
module top;
  sub u();
  logic [1:0] y; logic z;
  assign y = u.st[1].f.g;
  assign z = u.st[0].f.h;
endmodule
