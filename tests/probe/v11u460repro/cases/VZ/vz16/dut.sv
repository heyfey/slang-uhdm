// § elemBitsByExprEvalSize460v § clsArrPatBasedLitElemW460 (real and shortreal fixed class arrays)
class C;
  real rf[2] = '{'h5, 'h6};
  shortreal sf[2] = '{'h7, 'h8};
endclass
module top;
  initial begin C c; c = new; end
endmodule
