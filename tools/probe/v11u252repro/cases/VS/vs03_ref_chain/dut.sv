// § ternLeafThroughParamRef252
package p;
  typedef enum { E0, E1, E2 } e_t;
  typedef struct packed { integer a; integer b; integer c; } s_t;
  localparam s_t A = '{a : 1, b : 2, c : 3};
  localparam s_t B = A;
  localparam s_t C = B;
  localparam s_t O = '{a : 0, b : 5, c : 0};
  localparam s_t M = '{a : (O.a == 0) ? C.a : O.a, b : (O.b == 0) ? C.b : O.b, c : (O.c == 0) ? C.c : O.c};
endpackage
module top import p::*; #(parameter Q = 1) (output logic [31:0] o);
  assign o = M.a + M.b;
endmodule
