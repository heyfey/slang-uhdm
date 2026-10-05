// § clsTdUnionBuilt237
// a packed class union read by a module variable through the class scope
package p;
class a;
  typedef union packed { logic [7:0] x; bit [7:0] y; } u_t;
endclass
endpackage
module top (output logic [7:0] o);
  p::a::u_t v;
  assign v.x = 8'h3;
  assign o = v.y;
endmodule
