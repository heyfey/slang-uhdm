// § clsSpecSurelogOrder436
class C #(parameter p = 2, type T = int);
  T x;
endclass
class E;
  C#(3, byte) h;
endclass
module top;
  E e;
endmodule
