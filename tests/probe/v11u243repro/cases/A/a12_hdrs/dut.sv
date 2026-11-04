// § thisNetSurelogAnchor243
// headers included into two packages; the module imports the later package first
package p1;
  `include "h1.svh"
endpackage
package p2;
  `include "h2.svh"
endpackage
module top;
  import p2::*;
  import p1::*;
endmodule
