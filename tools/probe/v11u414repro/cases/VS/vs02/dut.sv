// § structMemberDefault414
package p;
  typedef struct { int a = 3; } s_t;
endpackage
module top;
  p::s_t s;
endmodule
