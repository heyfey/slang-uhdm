// § clsTdUnionBuilt237
// a union typedef inside a class inside a module
module top;
class a;
  typedef union packed { logic [7:0] x; bit [7:0] y; } u_t;
  u_t v;
endclass
  a h = new;
endmodule
