// § clsArrPatBasedLitElemW460 (signed based literals)
class C;
  byte a[] = '{'sh7f, 8'sh80, 'sb11};
endclass
module top;
  initial begin C c; c = new; end
endmodule
