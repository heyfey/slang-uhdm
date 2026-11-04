// § clsNestedUnsizedDims464 (a real element)
class C;
  real dd[][];
endclass
module top;
  initial begin C c; c = new; end
endmodule
