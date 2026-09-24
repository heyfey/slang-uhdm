// v11u66 adversarial arm a3 — PER-INSTANCE.  The patch re-evaluates the
// STRIPPED setter through `ectx.tryEval`, a second evaluation beside the
// `uvm` the mint already holds.  If that context is not the instance's, two
// instantiations with DIFFERENT overrides would both print the same digits
// (or the definition default), which is a value AWAY from golden.
package qa3;
  typedef struct packed { logic [31:0] a; logic [31:0] b; } ca3_t;
endpackage
module a3sub #(parameter int P = 3) (output logic [31:0] y, output logic [31:0] z);
  localparam qa3::ca3_t Q = '{a: P * 2, b: P - 100};
  assign y = Q.a;
  assign z = Q.b;
endmodule
module a3_inst66 (output logic [31:0] y1, output logic [31:0] z1,
                  output logic [31:0] y2, output logic [31:0] z2,
                  output logic [31:0] y3, output logic [31:0] z3);
  a3sub #(.P(5))  u1 (.y(y1), .z(z1));   // golden: a = 10,  b = -95
  a3sub #(.P(7))  u2 (.y(y2), .z(z2));   // golden: a = 14,  b = -93
  a3sub           u3 (.y(y3), .z(z3));   // the DEFAULT: a = 6, b = -97
endmodule
