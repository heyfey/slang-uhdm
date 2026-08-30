// v8_mix102 -- THE DISCRIMINATOR, re-measured independently: a MODULE's own
// array sized by an IMPORTED PACKAGE parameter (must NOT fold), beside the
// package twin (must fold); plus the INTERFACE and PACKAGE-RE-EXPORT homes and
// a package array whose ELEMENT is a package typedef carrying its own dim.
package v8a102;
  parameter int SN = 3;
  parameter int SPKG [0:SN-1] = '{1,2,3};             // package array, package size -> FOLD
endpackage

package v8b102;                                       // re-export home
  import v8a102::*;
  parameter int BN = 3;
  parameter int BARR [0:BN-1] = '{1,2,3};
endpackage

module v8mod102;
  import v8a102::*;
  localparam int LOCN = 3;
  localparam int MIX_PKGSIZE  [0:SN-1]   = '{1,2,3};  // MODULE array, PACKAGE size -> NO FOLD
  parameter  int MIXP_PKGSIZE [0:SN-1]   = '{1,2,3};  // MODULE param, PACKAGE size -> NO FOLD
  localparam int MIX_MODSIZE  [0:LOCN-1] = '{1,2,3};  // MODULE array, module size  -> NO FOLD
  int t = SPKG[0] + MIX_PKGSIZE[0] + MIXP_PKGSIZE[0] + MIX_MODSIZE[0];
endmodule

interface v8if102;
  import v8a102::*;
  localparam int IFN = 3;
  localparam int IF_MODSIZE [0:IFN-1] = '{1,2,3};     // INTERFACE array -> NO FOLD
  localparam int IF_PKGSIZE [0:SN-1]  = '{1,2,3};     // INTERFACE array, package size -> NO FOLD
  int t = SPKG[0] + IF_MODSIZE[0] + IF_PKGSIZE[0];
endinterface

module v8sub102;
  import v8b102::*;
  int t = BARR[0];
endmodule

module v8_mix102;
  v8mod102 u_m();
  v8sub102 u_s();
  v8if102  u_if();
endmodule
