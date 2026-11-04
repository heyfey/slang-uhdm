// § clsInnerUnsizedAnyElem464 (a vector and a string element)
class C;
  logic [3:0] v[2][];
  string s[2][];
endclass
module top;
  initial begin C c; c = new; end
endmodule
