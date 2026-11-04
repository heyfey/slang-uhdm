// § pkgExplicitImpParamReExport453
package a;
  parameter int PA = 1;
endpackage
package b;
  import a::PA;
endpackage
package b2;
  import a::PA;
endpackage
package c;
  import b::*;
  import b2::*;
endpackage
module top;
  import c::*;
endmodule
