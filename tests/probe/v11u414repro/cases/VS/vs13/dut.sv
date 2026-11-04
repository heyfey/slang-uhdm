// § structMemberDefault414
class C;
  typedef struct { int a = 3; } s_t;
  s_t s;
endclass
module top;
  C c;
endmodule
