// § pkgExplicitImpVarReExport453
package a;
  logic [3:0] va;
  wire [1:0] wn;
endpackage
package b;
  import a::wn;
  import a::va;
endpackage
interface ifc;
  import b::*;
endinterface
module top;
  import b::*;
  ifc u();
endmodule
