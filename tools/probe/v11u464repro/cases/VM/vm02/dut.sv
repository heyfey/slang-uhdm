// § clsInnerUnsizedAnyElem464 (a string element with an inner queue)
class C;
  string m[3][$];
endclass
module top;
  initial begin C c; c = new; end
endmodule
