// § patFlatBinLeftSpan252
package p;
  typedef enum { E0, E1, E2 } e_t;
  typedef struct packed { integer a; integer b; integer c; } s_t;
  localparam integer K = 3;
  localparam s_t D = '{a : (K > 2), b : -K + 4, c : (K + 1) * 2};
  localparam s_t F = '{a : K && 1, b : K == 3, c : K ** 2};
  localparam s_t O = '{a : 0, b : 5, c : 0};
  localparam s_t M = '{a : (O.a == 0) ? D.a : F.a, b : (O.b == 0) ? D.b : F.b, c : (O.c == 0) ? D.c : F.c};
endpackage
module top import p::*; #(parameter Q = 1) (output logic [31:0] o);
  assign o = M.c;
endmodule
