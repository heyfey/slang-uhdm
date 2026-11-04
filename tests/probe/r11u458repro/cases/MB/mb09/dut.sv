// § subrAggCopyNamesByChain458
package p;
  typedef bit [7:0] a_t;
  typedef enum bit [1:0] {R, W} k_e;
  typedef struct { k_e kind; a_t addr; } op_s;
  class C;
    extern task t();
    extern function void pf(k_e pol);
  endclass
  function void C::pf(k_e pol);
    k_e recursion_policy;
    recursion_policy = pol;
  endfunction
  task C::t();
    op_s q[$];
    op_s one;
    k_e e;
    q.push_back(one);
  endtask
endpackage
package ap;
  import p::*;
  class D;
    C c;
  endclass
endpackage
module hvl_top;
  import p::*;
  import ap::*;
  op_s s;
  k_e ee;
endmodule
module hdl_top;
  import p::*;
  op_s s2;
  k_e ee2;
endmodule
