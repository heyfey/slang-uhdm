// § clsNestedUnsizedDims464 (class handle elements)
class K; int x; endclass
class C;
  K h[][];
endclass
module top;
  initial begin C c; c = new; end
endmodule
