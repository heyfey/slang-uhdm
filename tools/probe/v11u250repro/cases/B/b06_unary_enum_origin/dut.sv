// § patFlatTernPickedLeafSpan250
// origins written as a unary operation, an enum name, a parenthesized literal and a cast, read through ?: in an importing module
package p;
  typedef enum logic [1:0] { E0, E1, E2 } e_t;
  typedef struct packed { logic [3:0] a; e_t e; logic [3:0] c; logic [3:0] d; } s_t;
  localparam s_t O = '{a: ~4'd1, e: E2, c: (4'd5), d: 4'(7)};
  localparam s_t P = '{a: 1 ? O.a : 4'd0, e: 0 ? E0 : O.e, c: O.c, d: O.d};
endpackage
module top(output logic [3:0] a, c, d, output logic [1:0] e);
  import p::*;
  assign a = P.a;
  assign e = P.e;
  assign c = P.c;
  assign d = P.d;
endmodule
