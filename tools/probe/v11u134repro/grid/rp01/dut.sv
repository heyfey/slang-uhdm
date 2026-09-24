// § pkgTsRefObjChainName134
package p;
  parameter int N = 4;
  typedef logic [N-1:0] n_t;
  typedef struct packed { n_t f; logic [N:0] g; } s_t;
  parameter s_t D = '0;
endpackage
module top(output logic [3:0] o);
  assign o = p::D.f;
endmodule
