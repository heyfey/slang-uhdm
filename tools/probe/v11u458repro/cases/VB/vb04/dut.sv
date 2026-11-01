// § subrAggCopyNamesByChain458
package p;
  typedef bit [7:0] a_t;
  typedef enum bit [1:0] {R, W} k_e;
  typedef struct { k_e kind; a_t addr; } op_s;
endpackage
package p2;
  import p::*;
  function automatic void ff(output op_s o, ref k_e k, input op_s i);
    op_s tmp;
    tmp = i;
    o = tmp;
  endfunction
endpackage
package ap;
  import p2::*;
  import p::*;
  int z;
endpackage
module hvl_top;
  import p::*;
  import ap::*;
  op_s s;
endmodule
module hdl_top;
  import p::*;
  op_s s2;
endmodule
