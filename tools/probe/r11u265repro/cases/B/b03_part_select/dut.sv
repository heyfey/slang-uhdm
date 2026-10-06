// § cloneBitSelMemberBind265 (a part select on the member: the law does not reach it)
package p;
  typedef struct { bit [7:0] byte_en; int data; } op_t;
  class c;
    extern function void f();
  endclass
  function void c::f();
    begin
      op_t rw;
      rw.byte_en[3:0] = 4'hf;
    end
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import p::*;
endmodule
