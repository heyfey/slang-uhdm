// § pkgExplicitImpParamReExport453
package a;
  parameter int PA = 1;
endpackage
package b;
  import a::PA;
endpackage
interface ifc;
  import b::*;
  logic x;
endinterface
module top;
  ifc u();
endmodule
