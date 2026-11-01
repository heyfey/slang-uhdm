// § subrAggCopyNamesByChain458
package p;
  typedef bit [7:0] a_t;
  typedef enum bit [1:0] {R, W} k_e;
  typedef struct { k_e kind; a_t addr; } op_s;
endpackage
module hvl_top;
  import p::*;
  op_s s;
  for (genvar i = 0; i < 2; i++) begin : g
    function automatic op_s f(op_s a);
      op_s r;
      r = a;
      return r;
    endfunction
    op_s gs;
    initial gs = f(s);
  end
endmodule
module hdl_top;
  import p::*;
  op_s s2;
endmodule
