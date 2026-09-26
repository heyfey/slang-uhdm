// § pkgPatUnqualReadTsNoParent178
package p;
  typedef struct { int unsigned A; int unsigned D; } cfg_t;
  localparam cfg_t B = '{A:2, D:8};
  function automatic int f(); cfg_t x; x = B; return x.D + B.A; endfunction
endpackage
module top; int r; initial r = p::f(); endmodule
