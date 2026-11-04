// § clsInnerUnsizedAnyElem464 (two fixed dims then a dynamic one)
class C;
  real m[2][3][];
endclass
module top;
  initial begin C c; c = new; end
endmodule
