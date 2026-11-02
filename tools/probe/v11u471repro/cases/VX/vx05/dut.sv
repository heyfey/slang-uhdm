// § pkgExportItemReImports471
// one export declaration with two items from two packages
package a; parameter int PA = 1; endpackage
package e; parameter int PE = 2; endpackage
package b;
  import a::*;
  import e::*;
  export a::PA, e::*;
endpackage
module top(output int y);
  import b::*;
  assign y = 0;
endmodule
