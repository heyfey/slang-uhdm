// § impStructRefOpAtRef252
package p;
  typedef enum { E0, E1, E2 } e_t;
  typedef struct packed { integer a; integer b; integer c; } s_t;
  localparam s_t D = '{a : 1, b : 2, c : 3};
  localparam s_t U = D;
  localparam s_t O = '{a : 0, b : 5, c : 0};
  localparam s_t M = '{a : (O.a == 0) ? U.a : O.a, b : (O.b == 0) ? U.b : O.b, c : (O.c == 0) ? U.c : O.c};
endpackage
package q;
  import p::*;
endpackage
module top import p::*; #(parameter Q = 1) ();
endmodule
