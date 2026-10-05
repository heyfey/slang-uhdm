// § thisNetSurelogAnchor243
// two headers included in the opposite order to their names: the wire sits in the first included header
package p;
`include "zz.svh"
`include "aa.svh"
endpackage
module top;
  import p::*;
endmodule
