// § clsInnerUnsizedAnyElem464
class C;
  real m[2][];
endclass
module top;
  initial begin C c; c = new; end
endmodule
