// v3_xpkg102 -- a PACKAGE-owned array parameter whose sizing identifier lives
// in ANOTHER package (imported bare, and scope-resolved), plus a package
// localparam sizing a package parameter.
package v3a102;
  parameter int XN = 4;
endpackage

package v3b102;
  import v3a102::*;
  parameter int IMPARR [0:XN-1]        = '{default:0};   // bare imported ident
  parameter int SCPARR [0:v3a102::XN-1]= '{default:0};   // scoped (ScopedName)
  localparam int LOCN = 3;
  parameter int LOCARR [0:LOCN-1]      = '{1,2,3};       // sized by a package localparam
  localparam int LLARR [0:LOCN-1]      = '{1,2,3};       // localparam array, localparam size
endpackage

module v3sub102;
  import v3b102::*;
  int t = IMPARR[0] + SCPARR[0] + LOCARR[0] + LLARR[0];
endmodule

module v3_xpkg102;
  v3sub102 u_a();
endmodule
