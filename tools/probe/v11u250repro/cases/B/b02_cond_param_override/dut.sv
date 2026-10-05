// § patFlatTernPickedLeafSpan250
// a ?: member whose condition is a parameter overridden differently at two instances
package p;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  localparam s_t DF = '{a: 4'd3, b: 4'd4};
endpackage
module sub #(parameter bit SEL = 0) (output logic [3:0] o);
  import p::*;
  localparam s_t C = '{a: SEL ? DF.a : 4'd9, b: DF.b};
  assign o = C.a + C.b;
endmodule
module top(output logic [3:0] o1, o2);
  sub #(.SEL(1)) u1(.o(o1));
  sub #(.SEL(0)) u2(.o(o2));
endmodule
