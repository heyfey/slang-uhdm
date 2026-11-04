// § pkgPatUnqualReadTsNoParent178
package p;
  typedef struct { int unsigned A; int unsigned D; } cfg_t;
  localparam cfg_t B = '{A:2, D:8};
  class K;
    function int g(); return B.D; endfunction
  endclass
endpackage
module top; endmodule
