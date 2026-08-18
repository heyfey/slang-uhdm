// r10rgg15 grid g3 — THE HEAD'S OWN SHAPE: a PARAMETER-DEPENDENT width
// `bit [W-1:0] P = '0` whose W is overridden per instance, with P itself both
// left at its default and overridden by '0 / by a sized literal.
// MEASUREMENT ONLY.
module g3_sub #(
  parameter int         W  = 8,
  parameter bit [W-1:0] P  = '0,
  parameter bit [W-1:0] Q  = '1,
  parameter logic [W-1:0] R = '0,
  parameter     [W-1:0] S  = '0
)();
endmodule

module g3_top;
  g3_sub                             u_defW  ();  // W=8, P default
  g3_sub #(.W(2))                    u_w2    ();  // W=2, P default
  g3_sub #(.W(2), .P('0))            u_w2z   ();  // W=2, P overridden by '0
  g3_sub #(.W(1), .P('0))            u_w1z   ();
  g3_sub #(.W(33), .P('0))           u_w33z  ();
  g3_sub #(.W(65), .P('0))           u_w65z  ();
  g3_sub #(.W(2), .P(2'h0))          u_w2s   ();  // sized-literal control
  g3_sub #(.W(2), .P('1), .Q('0))    u_w2o   ();
endmodule
