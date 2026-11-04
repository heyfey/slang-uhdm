// § clsNestedUnsizedDims464
class C;
  int dd[][];
  int q[$][];
endclass
module top;
  initial begin C c; c = new; end
endmodule
