// § unionRetVarAtTypeToken237
// an interface function returning a union typedef of the interface
interface ifc;
  typedef union packed { logic [7:0] x; bit [7:0] y; } u_t;
  function automatic u_t mk(logic [7:0] a);
    mk.x = a;
  endfunction
endinterface
module top (input logic [7:0] i, output logic [7:0] o);
  ifc u ();
  logic [7:0] t;
  assign t = u.mk(i);
  assign o = t;
endmodule
