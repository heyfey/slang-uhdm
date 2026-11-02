// § pkgExportItemReImports471
// export of a typedef only (not a parameter) and *::*
package a;
  typedef logic [3:0] t;
  parameter t PT = 4'd3;
endpackage
package b;
  import a::t;
  import a::PT;
  export a::t;
  export *::*;
endpackage
package c;
  import b::*;
endpackage
module top(output logic [3:0] y);
  import c::*;
  assign y = 4'd1;
endmodule
