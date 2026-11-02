// § pkgExportItemReImports471
// export of a::PA from b, with b's own parameter declared first
package a;
  parameter int PA = 5;
endpackage
package b;
  import a::PA;
  parameter int PB = 2;
  export a::PA;
endpackage
module top(output logic [31:0] y);
  import b::*;
  assign y = PA;
endmodule
