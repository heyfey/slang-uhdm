// § clsNestedUnsizedDims464 (in a parameterized class)
class C #(int W = 4);
  logic [W-1:0] d[][];
endclass
module top;
  initial begin C #(8) c; c = new; end
endmodule
