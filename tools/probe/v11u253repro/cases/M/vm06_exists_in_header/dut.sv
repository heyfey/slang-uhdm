// § cloneMintParentHomeCall253 (the home in an included header, the header in two packages)
package p;
  `include "inc.svh"
endpackage
package p2;
  `include "inc.svh"
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
