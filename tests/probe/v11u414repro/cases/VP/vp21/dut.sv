// § classPropBinOpInit414
class C;
  typedef struct packed { logic [3:0] f; } s_t;
  s_t x = 1 + 2;
endclass
module top;
  C c;
endmodule
