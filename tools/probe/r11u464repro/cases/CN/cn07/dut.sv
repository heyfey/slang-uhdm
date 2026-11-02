// § clsNestedUnsizedDims464 (an inner bounded queue)
class C;
  int f[][$:3];
endclass
module top;
  initial begin C c; c = new; end
endmodule
