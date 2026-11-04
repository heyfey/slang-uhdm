// § pkgImpParamsAheadOfOwn453
package a;
  parameter int PA = 1;
endpackage
package b;
  parameter int PB = 2;
  import a::PA;
endpackage
module top;
  import b::*;
endmodule
