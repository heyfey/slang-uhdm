// § pkgPatReadTsNoParent131
package pk;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  parameter s_t P = '{a: 4'h1, b: 4'h2};
endpackage
package q;
  parameter logic [3:0] A = pk::P.a;
endpackage
module top (output logic [3:0] o);
  assign o = q::A;
endmodule
