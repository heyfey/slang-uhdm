// § impStructRefOpAtRef252 (decode only: the home package DEFINITION listing substitutes an unread `U = D`; stage 1 on both binaries)
package p;
  typedef struct packed { int a; int b; } s_t;
  localparam s_t D = '{a : 1, b : 2};
  localparam s_t U = D;
endpackage
module top import p::*; #(parameter Q = 1) ();
endmodule
