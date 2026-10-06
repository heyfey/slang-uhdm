// § impStructRefOpAtRef252
package p;
  typedef enum { E0, E1, E2 } e_t;
  typedef struct packed { int a; int b; } s_t;
  localparam s_t D = '{a : 1, b : 2};
  localparam s_t U = D;
  localparam s_t O = '{a : 3, b : 0};
  localparam s_t M = '{a : (O.a == 0) ? U.a : O.a, b : (O.b == 0) ? U.b : O.b};
endpackage
module top import p::*; ();
endmodule
