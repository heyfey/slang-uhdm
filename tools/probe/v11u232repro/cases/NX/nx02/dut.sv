// § structCopyNestedAnnotDeep232
package p;
  typedef struct { int a = 1; bit f = 1'b1; } in_t;
  typedef struct { in_t i; int d = 4; } out_t;
endpackage
// member defaults under parameters
module child import p::*; #(parameter out_t P = '{i: '{a: 2, f: 0}, d: 5}) (output int o);
  assign o = P.i.a + P.d;
endmodule
module top import p::*; (output int o, output int q);
  child u1 (.o(o));
  child #(.P('{i: '{a: 3, f: 1}, d: 6})) u2 (.o(q));
endmodule
