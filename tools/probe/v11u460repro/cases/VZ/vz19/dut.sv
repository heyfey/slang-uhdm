// § elemBitsByExprEvalSize460v § clsArrPatBasedLitElemW460 (time, realtime and integer class arrays)
class C;
  time t[] = '{'h1, 'h2};
  realtime rt[2] = '{'h3, 'h4};
  integer gi[$] = '{'h5, 'h6};
  time tq[$] = {'h7, 'h8};
endclass
module top;
  initial begin C c; c = new; end
endmodule
