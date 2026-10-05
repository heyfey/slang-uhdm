// § clsTdUnionBuilt237
// an unpacked union typedef in a class with a struct member and a class variable
package p;
class a;
  typedef struct { int x; byte y; } s_t;
  typedef union { s_t s; int i; } u_t;
  u_t v;
endclass
endpackage
module top;
  p::a h = new;
endmodule
