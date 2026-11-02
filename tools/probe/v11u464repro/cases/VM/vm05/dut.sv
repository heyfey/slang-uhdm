// § clsInnerUnsizedAnyElem464 (control: a bit vector element)
class C;
  bit [3:0] m[2][];
endclass
module top;
  initial begin C c; c = new; end
endmodule
