// § cloneBitSelMemberBind265 (a packed union member)
package p;
  typedef union packed { logic [7:0] raw; logic [7:0] bits; } u_t;
  class c;
    extern function logic f(int z);
  endclass
  function logic c::f(int z);
    begin
      u_t u;
      u.raw = 8'h5;
      return u.bits[z];
    end
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import p::*;
endmodule
