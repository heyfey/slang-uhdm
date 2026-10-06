// § cloneSharedAggOwnCopy265 (a packed union with an enum member, local in the copy)
package p;
  typedef enum logic [1:0] {OK, NOK} st_e;
  typedef union packed { logic [1:0] raw; st_e status; } op_u;
  class c;
    extern function st_e f(st_e s1);
    extern function void g(st_e s2);
  endclass
  function st_e c::f(st_e s1);
    begin
      op_u u;
      u.raw = 2'b01;
      return u.status;
    end
  endfunction
  function void c::g(st_e s2);
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import p::*;
endmodule
