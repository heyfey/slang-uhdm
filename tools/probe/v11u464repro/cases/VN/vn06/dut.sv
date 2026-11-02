// § clsNestedUnsizedDims464 (a dynamic dim then a queue)
class C;
  int d[][$];
endclass
module top;
  initial begin C c; c = new; end
endmodule
