// § cloneBitSelMemberBind265 (fresh: two struct types with a same-named member, two roots in one method)
package p;
  typedef struct { bit [7:0] byte_en; int data; } op_t;
  typedef struct { logic [15:0] byte_en; } op2_t;
  class c;
    extern function void f(int z);
  endclass
  function void c::f(int z);
    op_t rw;
    op2_t rx;
    rw.byte_en[z] = 1'b1;
    rx.byte_en[z] = 1'b0;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import p::*;
endmodule
