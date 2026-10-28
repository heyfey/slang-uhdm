// § pkgExplicitImpParamReExport453
package a;
  parameter int PA = 1;
endpackage
package b;
  import a::PA;
  int vb;
endpackage
module sub;
  import b::*;
endmodule
module top;
  sub u1();
  sub u2();
endmodule
