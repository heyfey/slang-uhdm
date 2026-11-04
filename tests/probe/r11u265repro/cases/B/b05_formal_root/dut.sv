// § cloneBitSelMemberBind265 (the root is a formal of the copied subroutine)
package p;
  typedef struct { bit [7:0] byte_en; int data; } op_t;
  function automatic void f(ref op_t rw, input int z);
    rw.byte_en[z] = 1'b0;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import p::*;
endmodule
