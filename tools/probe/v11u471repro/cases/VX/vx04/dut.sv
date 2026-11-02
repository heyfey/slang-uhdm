// § pkgExportItemReImports471
// chain of exports a -> b -> c, module reads PA through c
package a;
  parameter int PA = 11;
endpackage
package b;
  import a::*;
  export a::*;
endpackage
package c;
  import b::*;
  export b::*;
  export a::*;
endpackage
module top(output int y);
  import c::*;
  assign y = 1;
endmodule
