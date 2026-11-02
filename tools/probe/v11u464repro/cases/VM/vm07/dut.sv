// § clsInnerUnsizedAnyElem464 (an alias of shortreal)
typedef shortreal s_t;
class C;
  s_t m[2][];
endclass
module top;
  initial begin C c; c = new; end
endmodule
