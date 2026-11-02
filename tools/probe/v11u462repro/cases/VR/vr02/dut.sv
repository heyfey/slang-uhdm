// § clsDynRealArrPropElem462
class C #(type T = real);
  T d[];
endclass
module top;
  initial begin C c; c = new; end
endmodule
