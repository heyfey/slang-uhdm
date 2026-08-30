// va_mixdim102 -- MIXED size+range dims in ONE declaration (both paths inside
// one makeUnpackedArrayParamTs call), an EXPLICIT (non-wildcard) import, and a
// package array materialized TWO instance levels deep.
package vap102;
  parameter int N = 3;
  parameter int MIXD [N][0:N-1]     = '{default:0};   // size dim + range dim
  parameter int RMIX [0:N-1][N]     = '{default:0};   // range dim + size dim
  parameter int EXPL [0:N-1]        = '{1,2,3};
endpackage

module vainner102;
  import vap102::EXPL;                                 // EXPLICIT import
  import vap102::MIXD;
  import vap102::RMIX;
  int t = EXPL[0] + MIXD[0][0] + RMIX[0][0];
endmodule

module vamid102;
  vainner102 u_i();
endmodule

module va_mixdim102;
  vamid102 u_m();
endmodule
