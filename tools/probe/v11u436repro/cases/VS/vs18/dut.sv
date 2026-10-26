// § clsSpecSurelogOrder436
class D; endclass
class C #(parameter p = 2, type T = int);
  T h;
endclass
module top;
C#(5, D) v;
endmodule
