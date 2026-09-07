// v201 arm P — a package that IMPORTS and RE-EXPORTS, imported in turn.
package p201vp1;
  parameter P_A = 13;
endpackage
package p201vp2;
  import p201vp1::*;
  export p201vp1::*;
  parameter P_B = P_A;
endpackage
import p201vp2::*;
module m201vp;
endmodule
