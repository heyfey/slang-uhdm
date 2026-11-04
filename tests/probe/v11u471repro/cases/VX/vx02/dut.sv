// § pkgExportItemReImports471
// own parameter, then import and export of one parameter
package a;
  parameter int PA = 5;
  localparam int LA = 9;
endpackage
package b;
  parameter int QB = 2;
  import a::PA;
  export a::PA;
endpackage
module top(output int y);
  import b::*;
  assign y = QB;
endmodule
