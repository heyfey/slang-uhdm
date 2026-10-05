// § unionRetVarAtTypeToken237
// a package function returning a package union typedef by its qualified name, called in a cont_assign
package p;
  typedef union packed { logic [7:0] x; bit [7:0] y; } u_t;
  function automatic p::u_t mk(logic [7:0] a);
    mk.x = a;
  endfunction
endpackage
module top (input logic [7:0] i, output logic [7:0] o);
  p::u_t t;
  assign t = p::mk(i);
  assign o = t.y;
endmodule
