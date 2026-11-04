// § clsNestedUnsizedDims464 (a dynamic dim then a fixed one then a dynamic one)
class C;
  logic [3:0] e[][2][];
endclass
module top;
  initial begin C c; c = new; end
endmodule
