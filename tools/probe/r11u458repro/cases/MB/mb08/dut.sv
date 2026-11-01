// § subrAggCopyNamesByChain458
package p;
  typedef bit [7:0] a_t;
  typedef enum bit [1:0] {R, W} k_e;
  typedef struct { k_e kind; a_t addr; } op_s;
  typedef struct packed { a_t x; bit [7:0] y; } u_t;
  class C;
    extern task t();
  endclass
  task C::t();
    u_t un;
  endtask
  function automatic int ff(op_s a);
    op_s one;
    k_e e2;
    one = a;
    return 1;
  endfunction
endpackage
package ap;
  import p::*;
  int k;
endpackage
module hdl_top;
  import p::*;
  op_s s2;
endmodule
module hvl_top;
  import p::*;
  import ap::*;
  op_s s;
endmodule
