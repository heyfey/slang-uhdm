// § clsDynRealArrPropElem462
class C #(type T = int);
  T d[$];
endclass
module top;
  C #(real) a;
  C #(shortreal) b;
  initial begin a = new; b = new; end
endmodule
