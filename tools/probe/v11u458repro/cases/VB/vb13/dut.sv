// § subrAggCopyNamesByChain458
package p;
  typedef bit [7:0] a_t;
  typedef union { a_t x; int y; } u_t;
  class C;
    extern task t();
  endclass
  task C::t();
    u_t un;
    u_t uq[$];
    uq.push_back(un);
  endtask
endpackage
package ap;
  import p::*;
  class D; C c; endclass
endpackage
module hvl_top;
  import p::*;
  import ap::*;
  u_t s;
endmodule
module hdl_top;
  import p::*;
  u_t s2;
endmodule
