// § subrAggCopyNamesByChain458
package p;
  typedef bit [7:0] a_t;
  typedef struct { a_t addr; bit [1:0] k; } op_s;
endpackage
module sub;
  import p::*;
  task automatic t();
    op_s loc;
    op_s q[$];
    q.push_back(loc);
  endtask
  initial t();
endmodule
module hdl_top;
  import p::*;
  op_s s2;
  sub u();
endmodule
module hvl_top;
  import p::*;
  op_s s3;
endmodule
