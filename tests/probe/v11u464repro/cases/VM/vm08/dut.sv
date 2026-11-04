// § clsInnerUnsizedAnyElem464 (a realtime element)
class C;
  realtime m[2][];
endclass
module top;
  initial begin C c; c = new; end
endmodule
