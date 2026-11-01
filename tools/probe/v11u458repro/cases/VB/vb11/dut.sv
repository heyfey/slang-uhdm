// § subrAggCopyNamesByChain458
package p;
  typedef bit [7:0] a_t;
  typedef enum bit [1:0] {R, W} k_e;
  typedef struct { k_e kind; a_t addr; } op_s;
endpackage
module hvl_top;
  import p::*;
  op_s s;
  class K;
    task t();
      op_s loc;
      k_e e;
    endtask
  endclass
endmodule
module hdl_top;
  import p::*;
  op_s s2;
endmodule
