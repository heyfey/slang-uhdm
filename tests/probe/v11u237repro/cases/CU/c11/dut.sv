// § clsTdUnionBuilt237
// a tagged union typedef in a class
package p;
class a;
  typedef union tagged { int i; bit [7:0] b; } u_t;
endclass
endpackage
module top;
  p::a h = new;
endmodule
