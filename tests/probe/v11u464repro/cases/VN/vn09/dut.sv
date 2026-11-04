// § clsNestedUnsizedDims464 (a bounded leading queue then a dynamic dim)
class C;
  int q[$:4][];
endclass
module top;
  initial begin C c; c = new; end
endmodule
