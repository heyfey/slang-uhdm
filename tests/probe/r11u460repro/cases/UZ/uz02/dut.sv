// § clsArrPatBasedLitElemW460
class C;
  byte d[] = '{'h1, 'b11, 'o7, 'd5};
  bit [2:0] q[$] = '{'h1, 2};
endclass
module top;
  initial begin C c; c = new; end
endmodule
