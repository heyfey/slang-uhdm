// § structRandMemberVoid414
typedef struct { randc bit [3:0] a; int b; } s_t;
class C;
  rand s_t s;
endclass
module top;
  C c;
endmodule
