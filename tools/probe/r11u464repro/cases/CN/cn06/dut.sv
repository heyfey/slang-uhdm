// § clsNestedUnsizedDims464 (vector, byte and string elements)
class C;
  logic [7:0] v[][];
  byte b[][];
  string s[][];
endclass
module top;
  initial begin C c; c = new; end
endmodule
