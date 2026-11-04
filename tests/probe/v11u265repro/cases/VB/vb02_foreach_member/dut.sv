// § cloneBitSelMemberBind265 (fresh: the bit select is the loop's own index inside a foreach over the member)
package p;
  typedef struct { bit [7:0] byte_en; int data; } op_t;
  class c;
    extern function void f();
  endclass
  function void c::f();
    op_t rw;
    foreach (rw.byte_en[i]) rw.byte_en[i] = 1'b1;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import p::*;
endmodule
