// § contAssignVarInitRhsShared420
module top;
  typedef struct packed { logic [7:0] a; } s_t;
  s_t s;
  int c = 5;
  assign s.a = c;
endmodule
