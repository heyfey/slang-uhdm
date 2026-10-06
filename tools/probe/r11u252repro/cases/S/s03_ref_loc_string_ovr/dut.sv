// § ternLeafThroughParamRef252
package p;
  typedef enum { E0, E1, E2 } e_t;
  typedef struct packed { integer a; integer b; integer c; } s_t;
  localparam s_t D = '{a : 1, b : 2, c : 3};
  localparam s_t U = D;
  localparam s_t O = '{a : 5, default : "inv"};
  localparam s_t M = '{a : (O.a == "inv") ? U.a : O.a, b : (O.b == "inv") ? U.b : O.b, c : (O.c == "inv") ? U.c : O.c};
endpackage
module top import p::*; #(parameter Q = 1) ();
endmodule
