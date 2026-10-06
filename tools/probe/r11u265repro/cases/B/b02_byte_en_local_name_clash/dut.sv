// § cloneBitSelMemberBind265 (MiniAmiq #127418 reduced: the home subroutine also declares a variable named like the member)
package p;
  typedef struct { bit [7:0] byte_en; int data; } op_t;
  class c;
    extern task f(int n);
  endclass
  task c::f(int n);
    bit byte_en;
    op_t rw;
    for (int z = 0; z < n; z++)
      rw.byte_en[z] = 1'b1;
  endtask
endpackage
package q;
  import p::*;
endpackage
module top;
  import p::*;
endmodule
