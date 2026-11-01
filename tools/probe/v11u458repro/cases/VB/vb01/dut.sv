// § subrAggCopyNamesByChain458
package p;
  typedef bit [7:0] a_t;
  typedef enum bit [1:0] {R, W} k_e;
  typedef struct { k_e kind; a_t addr; } op_s;
endpackage
module hvl_top;
  import p::*;
  op_s s;
  function automatic op_s mk(input op_s a, input k_e k);
    op_s r;
    r = a;
    r.kind = k;
    return r;
  endfunction
  initial s = mk(s, R);
endmodule
module hdl_top;
  import p::*;
  op_s s2;
endmodule
