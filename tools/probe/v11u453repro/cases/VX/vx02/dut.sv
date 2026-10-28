// § pkgExplicitImpParamReExport453
package a;
  parameter logic [3:0] PA = 4'hA;
endpackage
package b;
  import a::PA;
endpackage
package c;
  import b::*;
endpackage
module top;
  import c::*;
  logic [3:0] o;
  assign o = 4'h1;
endmodule
