// § subrAggCopyNamesByChain458
package p;
  typedef bit [7:0] a_t;
  typedef enum bit [1:0] {R, W} k_e;
  typedef struct { k_e kind; a_t addr; } op_s;
endpackage
module hvl_top;
  import p::*;
  typedef struct { a_t addr; bit z; } op_s;
  op_s s;
  task automatic t();
    op_s loc;
    p::op_s ploc;
  endtask
  initial t();
endmodule
module hdl_top;
  import p::*;
  op_s s2;
endmodule
