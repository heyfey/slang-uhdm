// § patFlatTernPickedLeafSpan250
// a struct parameter overridden at the instance, read by member in a localparam pattern
package p;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
endpackage
module sub #(parameter p::s_t D = '{a: 4'd1, b: 4'd2}) (output logic [3:0] o, output logic [3:0] q);
  localparam p::s_t C = '{a: D.a, b: (1 ? D.b : 4'd0)};
  assign o = C.a;
  assign q = C.b;
endmodule
module top(output logic [3:0] o1, q1, o2, q2);
  sub #(.D('{a: 4'd5, b: 4'd6})) u1(.o(o1), .q(q1));
  sub u2(.o(o2), .q(q2));
endmodule
