// § clsNestedUnsizedDims464 (a static and a rand nested property)
class C;
  static int s[][];
  rand int r[][];
endclass
module top;
  initial begin C c; c = new; end
endmodule
