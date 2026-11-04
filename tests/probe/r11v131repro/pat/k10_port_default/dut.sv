// § pkgPatReadTsNoParent131
package pk;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  parameter s_t P = '{a: 4'h1, b: 4'h2};
endpackage
module sub #(parameter pk::s_t Q = pk::P) (output logic [7:0] o);
  assign o = Q;
endmodule
module top (output logic [7:0] o);
  sub u(.o(o));
endmodule
