// § clsInnerUnsizedAnyElem464 (a range-form fixed dim)
class C;
  real m[2:0][];
  string s[0:1][];
endclass
module top;
  initial begin C c; c = new; end
endmodule
