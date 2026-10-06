// § impPatConcatSelReadParents252 (decode only: ALL[Q] selecting a reference element `U` is substituted in the elaborated module, ours keeps the bit_select; stage 1 on both binaries)
package p;
  typedef struct packed { integer a; integer b; integer c; } s_t;
  localparam s_t D = '{a : 1, b : 2, c : 3};
  localparam s_t U = D;
  localparam s_t O = '{a : 0, b : 5, c : 0};
  localparam s_t M = '{a : (O.a == 0) ? U.a : O.a, b : (O.b == 0) ? U.b : O.b, c : (O.c == 0) ? U.c : O.c};
  localparam s_t [2:0] ALL = {M, U, D};
endpackage
module top import p::*; #(parameter Q = 1, localparam s_t P = ALL[Q]) ();
endmodule
