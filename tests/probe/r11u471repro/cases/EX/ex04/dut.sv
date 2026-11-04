// § pkgExportItemReImports471
// two explicit export items, a module reads through b
package a;
  parameter int PA = 5;
  parameter int PB = 6;
endpackage
package b;
  import a::PA;
  import a::PB;
  export a::PA, a::PB;
endpackage
module top(output logic [31:0] y);
  import b::*;
  assign y = PA + PB;
endmodule
