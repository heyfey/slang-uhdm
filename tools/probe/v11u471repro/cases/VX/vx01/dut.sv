// § pkgExportItemReImports471
// export before import, then a parameter, module reads through b
package a;
  parameter int PA = 5;
  parameter int PB = 6;
endpackage
package b;
  export a::*;
  import a::*;
  parameter int QB = PA + 1;
endpackage
module top(output int y);
  import b::*;
  assign y = PA;
endmodule
