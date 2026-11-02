// § pkgExportItemReImports471
// export of a localparam, explicitly
package a;
  localparam int LA = 7;
  parameter int PA = 3;
endpackage
package b;
  import a::LA;
  export a::LA;
  localparam int LB = 2;
endpackage
module top(output int y);
  import b::*;
  assign y = LB;
endmodule
