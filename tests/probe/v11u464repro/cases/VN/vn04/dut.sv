// § clsNestedUnsizedDims464 (an enum typedef element)
typedef enum logic [1:0] { A, B } e_t;
class C;
  e_t d[][];
endclass
module top;
  initial begin C c; c = new; end
endmodule
