// § taggedUnionElabSpan137
package p;
  typedef union tagged packed { logic [3:0] a; logic [3:0] b; } u_t;
endpackage
module top(output logic o);
  p::u_t v;
  assign o = v[0];
endmodule
