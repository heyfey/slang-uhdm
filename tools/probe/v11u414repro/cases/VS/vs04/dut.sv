// § structMemberDefault414
typedef struct { int a = 7; } s_t;
class C;
  s_t s;
endclass
module top;
  C c;
endmodule
