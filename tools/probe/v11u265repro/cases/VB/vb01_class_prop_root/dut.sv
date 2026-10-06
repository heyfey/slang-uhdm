// § cloneBitSelMemberBind265 (fresh: the root of v.m[i] is a class property, not a local)
package p;
  typedef struct { bit [7:0] byte_en; int data; } op_t;
  class c;
    op_t rw;
    extern function void f(int z);
  endclass
  function void c::f(int z);
    rw.byte_en[z] = 1'b1;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import p::*;
endmodule
