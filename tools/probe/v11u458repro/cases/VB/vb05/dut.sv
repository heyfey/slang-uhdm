// § subrAggCopyNamesByChain458
package p;
  typedef bit [7:0] a_t;
  typedef enum bit [1:0] {R, W} k_e;
  typedef struct { k_e kind; a_t addr; } op_s;
endpackage
package c;
  import p::*;
  class C;
    task t();
      begin : nb
        op_s inner;
        k_e ke;
      end
      fork
        begin
          op_s fk;
        end
      join
    endtask
  endclass
endpackage
package ap;
  import c::*;
  class D; C cc; endclass
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
