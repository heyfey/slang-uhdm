// § clsNestedUnsizedDims464 (three dynamic dims)
class C;
  byte d[][][];
endclass
module top;
  initial begin C c; c = new; end
endmodule
