// § clsNestedUnsizedDims464 (three dynamic dims)
class C;
  int c[][][];
endclass
module top;
  initial begin C c0; c0 = new; end
endmodule
