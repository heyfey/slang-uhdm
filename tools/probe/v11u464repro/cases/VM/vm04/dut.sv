// § clsInnerUnsizedAnyElem464 (a two-dimension packed logic element)
class C;
  logic [1:0][3:0] m[2][];
endclass
module top;
  initial begin C c; c = new; end
endmodule
