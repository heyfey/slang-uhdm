// § clsInnerUnsizedAnyElem464 (an alias of real)
typedef real r_t;
class C;
  r_t m[2][];
endclass
module top;
  initial begin C c; c = new; end
endmodule
