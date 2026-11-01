// § memberAliasFollowsMemberName458
package p;
  typedef bit [7:0] a_t;
  typedef enum bit [1:0] {R, W} k_e;
  typedef struct { k_e kind; a_t addr; } op_s;
  class C;
    task t();
      op_s q[$];
      k_e e;
      q.push_back('{R, 8'h1});
    endtask
  endclass
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
endmodule
module hdl_top;
  import p::*;
  op_s s2;
endmodule
