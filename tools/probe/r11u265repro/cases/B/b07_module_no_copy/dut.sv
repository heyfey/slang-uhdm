// § cloneBitSelMemberBind265 (no importer: the law has no copy to visit)
package p;
  typedef struct { bit [7:0] byte_en; int data; } op_t;
  function automatic void f(int z);
    op_t rw;
    rw.byte_en[z] = 1'b1;
  endfunction
endpackage
module top;
  import p::*;
  initial f(1);
endmodule
