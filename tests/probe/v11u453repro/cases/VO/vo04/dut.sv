// § pkgImpParamsAheadOfOwn453
package a;
  parameter int PA = 1;
endpackage
package b;
  localparam int PB = 2;
  import a::*;
endpackage
interface ifc;
  import b::*;
endinterface
module top;
  ifc u();
endmodule
