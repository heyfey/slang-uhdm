// § cloneBitSelMemberBind265 (two importer packages and an interface importing last)
package p;
  typedef struct { bit [7:0] byte_en; int data; } op_t;
  class c;
    extern function void f(int z);
  endclass
  function void c::f(int z);
    begin
      op_t rw;
      rw.byte_en[z] = 1'b1;
    end
  endfunction
endpackage
package q;
  import p::*;
endpackage
package q2;
  import p::*;
endpackage
interface ifc;
  import p::*;
endinterface
module top;
  ifc i();
endmodule
