// v5_home102 -- HOMES: gen scope, interface, class-in-package, a parameterized
// module with two overrides, and THREE instances of one package span.
package v5p102;
  parameter int PN = 3;
  parameter int PARR [0:PN-1] = '{1,2,3};
endpackage

interface v5if102;
  import v5p102::*;
  localparam int IN = 3;
  localparam int IARR [0:IN-1] = '{1,2,3};       // interface home -- must NOT fold
  int t = IARR[0] + PARR[0];
endinterface

class v5c102;
  localparam int CN = 3;
  localparam int CARR [0:CN-1] = '{1,2,3};       // class home -- must NOT fold
endclass

module v5par102 #(parameter int GN = 3) ();
  import v5p102::*;
  localparam int GARR [0:GN-1] = '{default:0};   // module param home, overridden
  int t = GARR[0] + PARR[0];
endmodule

module v5sub102;
  import v5p102::*;
  int t = PARR[0];
  if (1) begin : g_blk
    localparam int GSN = 3;
    localparam int GSARR [0:GSN-1] = '{1,2,3};   // gen-scope home -- must NOT fold
    int u = GSARR[0] + PARR[0];
  end
endmodule

module v5_home102;
  v5sub102 u_a();
  v5sub102 u_b();
  v5sub102 u_c();
  v5if102  u_if();
  v5par102 #(.GN(4)) u_p4();
  v5par102 #(.GN(5)) u_p5();
endmodule
