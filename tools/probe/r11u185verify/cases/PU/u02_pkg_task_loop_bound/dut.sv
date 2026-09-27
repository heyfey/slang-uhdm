// § pkgPatUnqualReadTsNoParent178
package p;
  typedef struct { int unsigned N; int unsigned M; } cfg_t;
  localparam cfg_t B = '{N:3, M:5};
  task automatic t(output int o);
    o = 0;
    for (int i = 0; i < B.N; i++) o += B.M;
  endtask
endpackage
module top; int r; initial p::t(r); endmodule
