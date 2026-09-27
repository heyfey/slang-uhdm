// § lvIdxMemberSelIsRead184: a member path ending in a select nested in another member path's index inside an lvalue index (two levels)
typedef struct packed { logic [7:0] f; } s_t;
module top;
  s_t s, t;
  logic [7:0] arr;
  int i;
  initial arr[t.f[s.f[i]]] = 1'b1;
endmodule
