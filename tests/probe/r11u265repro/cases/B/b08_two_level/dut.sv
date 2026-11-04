// § cloneBitSelMemberBind265 (a two-level member path: the select sits on the third element)
package p;
  typedef struct { bit [7:0] be; } in_t;
  typedef struct { in_t inner; int data; } op_t;
  class c;
    extern function void f(int z);
  endclass
  function void c::f(int z);
    begin
      op_t rw;
      rw.inner.be[z] = 1'b1;
    end
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import p::*;
endmodule
