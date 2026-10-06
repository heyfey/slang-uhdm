// § cloneBitSelMemberBind265 (the root is a package variable)
package p;
  typedef struct { bit [7:0] byte_en; int data; } op_t;
  op_t gv;
  function automatic void f(int z);
    gv.byte_en[z] = 1'b1;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import p::*;
endmodule
