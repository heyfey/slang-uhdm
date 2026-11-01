// § clsArrPatBasedLitElemW460 (two-dimension)
class C;
  int a[2][2] = '{'{'h1, 'h2}, '{'h3, 'h4}};
endclass
module top;
  int m[2][2] = '{'{'h1, 'h2}, '{'h3, 'h4}};
  initial begin C c; c = new; end
endmodule
