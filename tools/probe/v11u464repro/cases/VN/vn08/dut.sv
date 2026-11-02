// § clsNestedUnsizedDims464 (a dynamic dim then an associative dim)
class C;
  int d[][int];
endclass
module top;
  initial begin C c; c = new; end
endmodule
