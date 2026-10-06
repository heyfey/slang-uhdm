// § cloneBitSelMemberBind265 (fresh: an indexed part select and a constant bit select on the member)
package p;
  typedef struct { bit [7:0] byte_en; int data; } op_t;
  class c;
    extern function void f(int z);
  endclass
  function void c::f(int z);
    op_t rw;
    rw.byte_en[z+:2] = 2'b11;
    rw.byte_en[3] = 1'b0;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import p::*;
endmodule
