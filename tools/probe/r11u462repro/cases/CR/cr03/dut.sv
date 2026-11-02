// § clsDynRealArrPropElem462
class C;
  typedef real r_t;
  r_t r[];
  real m[2][];
endclass
module top;
  initial begin C c; c = new; end
endmodule
