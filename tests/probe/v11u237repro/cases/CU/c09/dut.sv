// § unionRetVarAtTypeToken237
// an out-of-body class method returning the class's union typedef
package p;
class a;
  typedef union packed { logic [7:0] x; bit [7:0] y; } u_t;
  extern function u_t mk(logic [7:0] q);
endclass
function a::u_t a::mk(logic [7:0] q);
  mk.x = q;
endfunction
endpackage
module top;
  p::a h = new;
endmodule
