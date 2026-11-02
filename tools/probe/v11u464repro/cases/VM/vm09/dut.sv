// § clsInnerUnsizedAnyElem464 (control: a scalar logic element)
class C;
  logic m[2][];
endclass
module top;
  initial begin C c; c = new; end
endmodule
