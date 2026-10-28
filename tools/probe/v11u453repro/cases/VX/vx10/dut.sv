// § pkgExplicitImpParamReExport453
package a;
  typedef enum {E0, E1} e_t;
  parameter int PA = 1;
endpackage
package b;
  import a::E1;
  import a::e_t;
endpackage
module top;
  import b::*;
endmodule
