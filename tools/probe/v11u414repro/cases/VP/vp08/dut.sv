// § classPropBinOpInit414
class C #(int P = 3);
  int x = P + 1;
endclass
module top;
  C #(5) c;
endmodule
