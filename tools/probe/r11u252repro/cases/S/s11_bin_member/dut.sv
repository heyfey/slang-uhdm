// § patFlatBinLeftSpan252
package p;
  typedef enum { E0, E1, E2 } e_t;
  typedef struct packed { integer a; integer b; integer c; } s_t;
  localparam s_t D = '{a : (1 << E1)
                          | (1 << E2), b : (1 << E1), c : 2 + 3};
  localparam s_t O = '{a : 0, b : 5, c : 0};
  localparam s_t M = '{a : (O.a == 0) ? D.a : O.a, b : (O.b == 0) ? D.b : O.b, c : (O.c == 0) ? D.c : O.c};
endpackage
module top import p::*; #(parameter Q = 1) ();
endmodule
