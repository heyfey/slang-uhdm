// § clsNestedUnsizedDims464 (bit vector elements)
class C;
  bit [7:0] d[][];
endclass
module top;
  initial begin C c; c = new; end
endmodule
