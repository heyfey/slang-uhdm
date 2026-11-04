// § clsInnerUnsizedAnyElem464 (a signed logic vector element)
class C;
  logic signed [3:0] m[2][];
endclass
module top;
  initial begin C c; c = new; end
endmodule
