// § unitAssocTdMultiDim406
typedef struct packed { logic a; logic [2:0] b; } s_t;
typedef s_t t2 [2][2];
module top;
  t2 v;
endmodule
