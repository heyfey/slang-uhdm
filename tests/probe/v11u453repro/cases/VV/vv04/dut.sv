// § pkgExplicitImpVarReExport453
package a;
  logic [7:0] va;
endpackage
package b;
  import a::va;
endpackage
package c;
  import b::*;
endpackage
module top;
  import c::*;
  logic [7:0] o;
  assign o = 8'h0;
endmodule
