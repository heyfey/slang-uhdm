// § cloneLoopVarAssocIdxTs258 (decode of MiniAmiq #127418: a bit select on a struct member in an importer copy; the sister ground's binder)
package p;
  typedef bit unsigned [63:0] addr_t;
  typedef struct {
    bit [7:0] byte_en;
    addr_t data;
  } op_t;
  class c;
    extern function int f(int z);
  endclass
  function int c::f(int z);
    op_t rw_access;
    rw_access.byte_en[z] = 1'b1;
    return int'(rw_access.data);
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import p::*;
endmodule
