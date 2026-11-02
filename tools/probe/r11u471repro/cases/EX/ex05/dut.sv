// § pkgExportItemReImports471
// enum parameter re-exported with export a::*, c imports b
package a;
  typedef enum logic [1:0] {E0, E1, E2} e_t;
  parameter e_t PE = E2;
endpackage
package b;
  import a::*;
  export a::*;
endpackage
package c;
  import b::*;
endpackage
module top;
  logic w;
endmodule
