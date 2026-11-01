// § subrAggCopyNamesByChain458
package p;
  typedef bit [7:0] a_t;
  typedef enum bit [1:0] {R, W} k_e;
  typedef struct { k_e kind; a_t addr; } op_s;
endpackage
interface bus_if;
  import p::*;
  op_s s;
  task automatic drive();
    op_s loc;
    k_e kk;
    loc.kind = kk;
    s = loc;
  endtask
endinterface
module hdl_top;
  import p::*;
  op_s s2;
  bus_if b();
endmodule
module hvl_top;
  import p::*;
  op_s s3;
endmodule
