// § structRandMemberVoid414
package p;
  typedef struct { rand int a; int b; } s_t;
endpackage
class C;
  rand p::s_t s;
endclass
module top;
  C c;
endmodule
