// § elemBitsByExprEvalSize460v § modArrPatBasedLitElemW460 (real, shortreal and realtime elements)
module top;
  real r[2] = '{'h1, 'h2};
  shortreal s[2] = '{'h3, 'h4};
  realtime t[] = '{'h5, 'h6};
  real q[$] = {'h7, 'h8};
endmodule
