// § subrAggCopyNamesByChain458
package p;
  typedef bit [7:0] a_t;
  class C;
    extern task t();
  endclass
  task C::t();
    typedef struct { a_t a; bit b; } ls_t;
    ls_t x;
    ls_t xq[$];
    xq.push_back(x);
  endtask
endpackage
package ap;
  import p::*;
  class D; C c; endclass
endpackage
module hvl_top;
  import p::*;
  import ap::*;
endmodule
module hdl_top;
  import p::*;
endmodule
