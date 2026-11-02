// § clsInnerUnsizedAnyElem464 (a real element with an inner queue)
class C;
  real m[2][$];
endclass
module top;
  initial begin C c; c = new; end
endmodule
