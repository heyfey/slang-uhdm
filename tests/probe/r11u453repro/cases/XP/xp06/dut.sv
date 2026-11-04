// § pkgExplicitImpParamReExport453
package a;
  parameter int PA = 1;
endpackage
package b;
  import a::PA;
endpackage
package c;
  import b::*;
endpackage
package d;
  import c::*;
  import b::*;
endpackage
module top;
endmodule
