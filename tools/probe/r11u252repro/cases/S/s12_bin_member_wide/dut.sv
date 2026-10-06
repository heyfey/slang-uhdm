// § patFlatBinLeftSpan252
package p;
  typedef enum { E0, E1, E2 } e_t;
  typedef struct packed { integer a; integer b; integer c; integer d; } s_t;
  localparam s_t D = '{a : (1 << 1) | (1 << 2), b : 4 * 2, c : (7 - 1), d : 3};
  localparam int X = D.a;
endpackage
module top import p::*; #(parameter Q = 1) ();
endmodule
