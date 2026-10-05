// § patFlatTernPickedLeafSpan250
// ?: conditions written as a constant function call, $bits, an x literal, a localparam, a nested ?: condition and a case-equality
package p;
  typedef struct packed { logic [3:0] a; logic [3:0] b; logic [3:0] c; logic [3:0] d; logic [3:0] e; } s_t;
  function automatic bit f(int x); return x > 2; endfunction
  localparam bit K = 1'b0;
  localparam s_t O = '{a: 4'd1, b: 4'd2, c: 4'd3, d: 4'd4, e: 4'd5};
  localparam s_t P = '{a: f(3) ? O.a : 4'd9,
                       b: ($bits(s_t) == 20) ? O.b : 4'd9,
                       c: 1'bx ? O.c : 4'd9,
                       d: K ? 4'd9 : (O.a == 4'd1 ? O.d : 4'd8),
                       e: (O.e === 4'd5) ? O.e : 4'd0};
endpackage
module top(output logic [19:0] o);
  import p::*;
  localparam s_t Q = '{a: P.a, b: P.b, c: P.c, d: P.d, e: P.e};
  assign o = Q;
endmodule
