// § subrAggCopyNamesByChain458
package p;
  typedef bit [7:0] a_t;
  typedef enum bit [1:0] {R, W} k_e;
  typedef struct { k_e kind; a_t addr; } op_s;
endpackage
package ap;
  import p::*;
  export p::*;
  function automatic int g(op_s a);
    op_s loc;
    loc = a;
    return 0;
  endfunction
endpackage
package bp;
  import ap::*;
  int z;
endpackage
module hvl_top;
  import p::*;
  import bp::*;
  op_s s;
endmodule
module hdl_top;
  import p::*;
  op_s s2;
endmodule
