// § clsDynRealArrPropElem462
class C;
  typedef real r_t;
  r_t r[];
endclass
module top;
  initial begin C c; c = new; end
endmodule
