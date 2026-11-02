// § pkgExportItemReImports471
// b imports a::* and a::PA and exports a::PA: three copies in b
package a;
  typedef logic [3:0] t;
  parameter t PA = 4'd9;
endpackage
package b;
  import a::*;
  import a::PA;
  export a::PA;
endpackage
module top;
  logic w;
endmodule
