// § unionRetVarAtTypeToken237
// a module function returning a union typedef declared in a package, imported
package p;
  typedef union packed { logic [7:0] x; bit [7:0] y; } u_t;
endpackage
module top import p::*; (input logic [7:0] i, output logic [7:0] o);
  function automatic u_t
      mk(logic [7:0] a);
    mk.x = a;
  endfunction
  u_t t;
  assign t = mk(i);
  assign o = t.y;
endmodule
