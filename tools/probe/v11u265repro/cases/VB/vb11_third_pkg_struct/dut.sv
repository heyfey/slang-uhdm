// § cloneBitSelMemberBind265 (fresh: the struct typedef comes from a third package r that p imports; the copy's package lists no re-listing)
package r;
  typedef struct { bit [7:0] byte_en; int data; } op_t;
endpackage
package p;
  import r::*;
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
