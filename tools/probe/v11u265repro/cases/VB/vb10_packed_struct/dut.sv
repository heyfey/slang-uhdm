// § cloneBitSelMemberBind265 (fresh: a packed struct member bit select)
package p;
  typedef struct packed { logic [7:0] byte_en; logic [7:0] data; } op_t;
  class c;
    extern function void f(int z);
  endclass
  function void c::f(int z);
    op_t rw;
    rw.byte_en[z] = 1'b1;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import p::*;
endmodule
