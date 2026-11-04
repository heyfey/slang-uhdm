// § clsInnerUnsizedAnyElem464 (an inner queue, shortreal and realtime)
class C;
  real q[3][$];
  shortreal s[2][];
  realtime t[2][];
endclass
module top;
  initial begin C c; c = new; end
endmodule
