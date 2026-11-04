// § cloneBitSelMemberBind265 (the select written inside a macro body)
`define SETB(V, I) V.byte_en[I] = 1'b1;
package p;
  typedef struct { bit [7:0] byte_en; int data; } op_t;
  class c;
    extern function void f(int z);
  endclass
  function void c::f(int z);
    begin
      op_t rw;
      `SETB(rw, z)
    end
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import p::*;
endmodule
