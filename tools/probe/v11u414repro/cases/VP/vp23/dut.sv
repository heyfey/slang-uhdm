// § classPropBinOpInit414
class B;
  int b = 1;
endclass
class C extends B;
  int x = b * 2;
endclass
module top;
  C c;
endmodule
