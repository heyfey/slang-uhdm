// § cloneFormalTsParented253 (a header included in two packages)
package p1;
  `include "inc.svh"
endpackage
package p2;
  `include "inc.svh"
endpackage
package q;
  import p1::*;
endpackage
module top;
  import q::*;
endmodule
