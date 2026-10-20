// § structRandMemberVoid414
class C;
  typedef struct { rand int a; rand bit [1:0] b; int c; } s_t;
  rand s_t s;
endclass
module top;
  C c;
endmodule
