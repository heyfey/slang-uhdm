// § incDecMemberPathIsLvalue124
typedef struct { int a; int b; } s_t; typedef struct { s_t in; int c; } o_t;
module top; s_t s; task t(); s.a--; endtask endmodule
