// § clsNestedUnsizedDims464 (a typedef element)
typedef logic [3:0] n_t;
class C;
  n_t t[][];
endclass
module top;
  initial begin C c; c = new; end
endmodule
