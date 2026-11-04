// § classPropBinOpInit414
class C;
  bit a = 1;
  bit b = 0;
  bit x = a && b;
  bit y = a | b;
endclass
module top;
  C c;
endmodule
