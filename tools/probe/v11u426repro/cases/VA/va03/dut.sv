// § unitFixedArrTdAliasClone426
typedef struct packed { logic [3:0] a; } s_t;
typedef logic [7:0] ua_t [0:3];
typedef ua_t ub_t;
typedef struct { ub_t m; int n; } st_t;
module test;
  st_t v;
endmodule
