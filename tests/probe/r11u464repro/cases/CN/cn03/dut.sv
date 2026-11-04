// § clsNestedUnsizedDims464 (an inner queue)
class C;
  int a[][$];
  int b[$][$];
endclass
module top;
  initial begin C c; c = new; end
endmodule
