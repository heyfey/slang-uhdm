// § subrAggCopyNamesByChain458
package p;
  typedef bit [7:0] a_t;
  typedef struct packed { a_t hi; a_t lo; } pk_s;
  typedef struct { pk_s w; a_t z; } nest_s;
  class C;
    extern task t();
  endclass
  task C::t();
    nest_s n;
    nest_s q[$];
    q.push_back(n);
  endtask
endpackage
package ap;
  import p::*;
  class D; C c; endclass
endpackage
module hvl_top;
  import p::*;
  import ap::*;
  nest_s s;
endmodule
module hdl_top;
  import p::*;
  nest_s s2;
endmodule
