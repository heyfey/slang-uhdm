// § clsPropSpecPaNoFile243
// the generic declared in an included header, the holder in another package
package p;
`include "gen.svh"
endpackage
package q;
  import p::*;
  class hold;
    gen#(byte) m;
  endclass
endpackage
module top;
  import q::*;
  hold h;
endmodule
