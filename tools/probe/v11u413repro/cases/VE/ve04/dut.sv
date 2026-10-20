// § emptyConcatArrayVar413
module top;
  int q[$], p[$];
  bit c;
  initial q = c ? {} : p;
endmodule
