// § clsNestedUnsizedDims464 (two unbounded queues)
class C;
  int q[$][$];
endclass
module top;
  initial begin C c; c = new; end
endmodule
