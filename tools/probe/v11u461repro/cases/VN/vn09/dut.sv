// § pkgNestedAnonAggMemberInst461
typedef struct packed { union packed { logic [3:0] a; bit [3:0] b; } u; bit [3:0] y; } s_t;
module top;
  s_t v;
endmodule
